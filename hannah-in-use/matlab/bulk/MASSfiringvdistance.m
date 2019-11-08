function f = MASSfiringvdistance(clusters,posstructure, dim)
%finds firing rate as a function of distance from reward

      set(0,'DefaultFigureVisible', 'off');
      clustspikenames = (fieldnames(clusters));
      spikenum = length(clustspikenames);
      posnames = (fieldnames(posstructure));
      posnum = length(posnames);
      pnames = {};
      for s = 1:posnum
        if contains(posnames(s), 'position')==1
          pnames(end+1) = (posnames(s));
        end
      end

pval = [];
slope = [];
rsq = [];

  for z = 1:length(pnames)
        currentname = char(pnames(z))
        posData = posstructure.(currentname);
        posData = fixpos(posData);
        % get date of spike
        date = strsplit(currentname,'date_'); %splitting at year rat12_2018_08_20_time
        date = char(date(1,2));
        date = strsplit(date,'_position'); %rat12_2018_08_20
        date = char(date(1,1));

        %Sum of (occprobs * mean firing rate per bin / overall mean rate) * log2 (mean firing rate per bin / overall mean rate)

        velthreshold = 12;
        vel = velocity(posData);
        vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
        fastvel = find(vel(1,:) > velthreshold);
        totaltime = length(fastvel)./30;
        posDataFast = posData(fastvel, :);
        xvalsFast = posDataFast(:,2);
        yvalsFast = posDataFast(:,3);

        psize = 3.5 * dim;
        xvals = posDataFast(:,2);
        yvals = posDataFast(:,3);
        xmin = min(posDataFast(:,2));
        ymin = min(posDataFast(:,3));
        xmax = max(posDataFast(:,2));
        ymax = max(posDataFast(:,3));
        xbins = ceil((xmax)/psize); %number of x
        ybins = ceil((ymax)/psize); %number of y
        xinc = (0:xbins)*psize; %makes a vectors of all the x values at each increment
        yinc = (0:ybins)*psize; %makes a vector of all the y values at each increment

      %Sum of (occprobs * mean firing rate per bin / meanrate) * log2 (mean firing rate per bin / meanrate)

      %spike rates
      cnames = {};

      cstart = 0;
      cend = 100000000;

      currentclusts = struct;
      for c = 1:(spikenum)
        name = char(clustspikenames(c));
        date;
        if contains(name, date)==1 & cstart==0
          [currentclusts(:).(name)] = deal(clusters.(name));
        end
      end

      currentclustname = (fieldnames(currentclusts));
      currentnumclust = length(currentclustname);

    if currentnumclust>0
      for c = 1:(currentnumclust)
        name = char(currentclustname(c));
          clust = currentclusts.(name);
          clustsize = length(clust);
          [clustmin indexmin] = min(abs(posData(1,1)-clust));
          [clustmax indexmax] = min(abs(posData(end,1)-clust));
          clust = clust(indexmin:indexmax);

          assvel = assignvelOLD(clust, vel);
          fastspikeindex = find(assvel > velthreshold);
          %meanrate = length(fastspikeindex)./(totaltime); %WANT ONLY AT HIGH VEL


          chart = normalizePosData(clust(fastspikeindex), posDataFast, dim);
          chart = ndnanfilter(chart, 'gausswin', 10./2*dim, 2, {}, {'replicate'}, 1);

          realX = [];
          realY = [];
          firinglinear = chart(:);
          for z=1:length(firinglinear)
              [currY currX] = ind2sub(size(chart),z);
              realX(end+1) = (xmax)./xbins .* (currY);
              realY(end+1) = (ymax)./ybins .* (currX);
          end

          dist = distancetoreward([realX; realY]);

          lm = fitlm(dist, firinglinear);
          pval(end+1) = (lm.Coefficients.pValue(2));
          slope(end+1) = (lm.Coefficients.Estimate(2));
          rsq(end+1) = lm.Rsquared.Ordinary;
        end
      end
    end

    f = [pval; rsq; slope]';
