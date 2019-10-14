function [f allsizescenters] = MASSplacefieldnumDIRECTIONAL_resid(clusters,posstructure, dim)

      set(0,'DefaultFigureVisible', 'off');

%determine how many spikes & pos files

allsizes = [];
allcenterXmean = [];
allcenterYmean = [];
allcenterXmax = [];
allcenterYmax = [];
allskew = [];
alldir = [];
alldirskew = [];
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

%output = {'cluster name'; 'cluster size'; 'direction'; 'num of fields'; 'field size in cm'; 'centermax'; 'centermean'; 'skewness'};
output = {'cluster name'; 'cluster size'; 'direction'; '1=to, 2=away'; 'field size in cm'; 'centermax X'; 'centermax Y'; 'skewness'; 'dir skewness'};

for z = 1:length(pnames)
  currentname = char(pnames(z))
  posData = posstructure.(currentname);
  posData = fixpos(posData);
  % get date of spike
  date = strsplit(currentname,'date_'); %splitting at year rat12_2018_08_20_time
  date = char(date(1,2));
  date = strsplit(date,'_position'); %rat12_2018_08_20
  date = char(date(1,1));

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
  acc = accel(posData);
  vel = velocity(posData);
  velthreshold = 12;
  vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
  acc(1,:) = smoothdata(acc(1,:), 'gaussian', 30);
  fastvel = find(vel(1,:) > velthreshold);
  totaltime = length(fastvel)./30;
  posDataFast = posData(fastvel, :);
  xvalsFast = posDataFast(:,2);
  yvalsFast = posDataFast(:,3);

  psize = 3.5 * dim;
%  xvals = posDataFast(:,2);
%  yvals = posDataFast(:,3);
%  xmin = min(posDataFast(:,2));
%  ymin = min(posDataFast(:,3));
%  xmax = max(posDataFast(:,2));
%  ymax = max(posDataFast(:,3));
  xbins = ceil((max(posDataFast(:,2)))/psize); %number of x
  ybins = ceil((max(posDataFast(:,3)))/psize); %number of y
  xinc = (0:xbins)*psize; %makes a vectors of all the x values at each increment
  yinc = (0:ybins)*psize; %makes a vector of all the y values at each increment

  %occupancy
  occ = zeros(xbins, ybins);
  testing = 0;
  for x = (1:xbins)
    for y = (1:ybins)
      if x<xbins & y<ybins
      occx = find(xvalsFast>=xinc(x) & xvalsFast<xinc(x+1));
      occy = find(yvalsFast>=yinc(y) & yvalsFast<yinc(y+1));
      elseif x==xbins & y<ybins
      occx = find(xvalsFast>=xinc(x));
      occy = find(yvalsFast>=yinc(y) & yvalsFast<yinc(y+1));
      elseif x<xbins & y==ybins
      occx = find(xvalsFast>=xinc(x) & xvalsFast<xinc(x+1));
      occy = find(yvalsFast>=yinc(y));
      elseif x==xbins & y==ybins
      occx = find(xvalsFast>=xinc(x));
      occy = find(yvalsFast>=yinc(y));
      end

      if length(intersect(occx, occy)) == 0
      occ(x,y) = NaN;
      else
      occ(x,y) = length(intersect(occx, occy));
      end
  end
  end

numocc = occ(~isnan(occ));
occtotal = sum(((numocc)), 'all');
occprobs = occ./(occtotal);
end
%Sum of (occprobs * mean firing rate per bin / meanrate) * log2 (mean firing rate per bin / meanrate)

%spike rates

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


    %finding directionality per spike

    dirinfo = direction(clust(fastspikeindex), posData); %outputs [timevector; xposvector; yposvector; fxvector; fyvector];

    %if left forced or right choice is negative in y direction, toward reward
    %if right forced or left choice is positive in y direction, toward reward
    %if middle is positive in x direction, toward reward
    %if middle is negative in x direction, away from reward
            %   1   2   3   4   5
    xlimmin = [300 300  750 780 430];
    xlimmax = [505 505  950 950 870];
    ylimmin = [370 000  380 000 300];
    ylimmax = [700 370  700 380 440];
    %position 1: left forced
    %position 2: right forced
    %position 3: left choice arm
    %position 4: right choice arm
    %position 5: middle stem

      toreward = [];
      awayreward = [];
      for k=1:length(xlimmin)

        inX = find(dirinfo(2,:) > xlimmin(k) & dirinfo(2,:) <=xlimmax(k)); %check to make sure correct indexing
        inY = find(dirinfo(3,:) > ylimmin(k) & dirinfo(3,:) <=ylimmax(k));
        inboth = intersect(inX, inY);
        if (k == 1 | k== 4) %if left forced or right choice is negative in y direction, toward reward
          yneg = find(dirinfo(5,:)<0);
          ypos = find(dirinfo(5,:)>0);
          toreward = [toreward, intersect(inboth, yneg)]; %indices of to
          awayreward = [awayreward, intersect(inboth, ypos)];

        elseif (k == 2 | k== 3) %if right forced or left choice is positive in y direction, toward reward
          yneg = find(dirinfo(5,:)<0);
          ypos = find(dirinfo(5,:)>0);
          awayreward = [awayreward, intersect(inboth, yneg)]; %indices of to
          toreward = [toreward, intersect(inboth, ypos)];
        elseif (k == 5) %if middle is positive in x direction, toward reward
          xneg = find(dirinfo(4,:)<0);
          xpos = find(dirinfo(4,:)>0);
          toreward = [toreward, intersect(inboth, xpos)]; %indices of to
          awayreward = [awayreward, intersect(inboth, xneg)];
        end
      end

      testing = intersect(toreward, awayreward);
      dirinfo(:, testing)';
      torewardspikes = dirinfo(1,toreward);
      awayrewardspikes = dirinfo(1,awayreward);

      %%%%%%%%%%%%

    %NOW DO CHARTS AND EVERYTHING FOR BOTH
    %spiking normalization chart
    for z=1:2;
      if z ==1;
        spikestochart = torewardspikes;
        dir = 'to';
        currentdir = 1;
      else
        spikestochart = awayrewardspikes;
        dir = 'away';
        currentdir = 2;
      end


    spikestochart = cutclosest(posDataFast(1,1), posDataFast(end,1), spikestochart, spikestochart);
    if length(spikestochart)<2
      continue
    end





    %%%%%%%%%%%%%%%%%%%
    veldata = vel;
    accdata = abs(acc);

    velpowerchart = powermap(veldata, posData, dim, 0, 50);
    accpowerchart = powermap(accdata, posData, dim, 0, 50);

    maxtime = max(posDataFast(:,1));
    currentpos = [posDataFast; [maxtime+.03, 0, 0]; [maxtime+.06, 1500, 1500]];

    xvals = currentpos(:,2);
    yvals = currentpos(:,3);
    xmin = min(currentpos(:,2));
    ymin = min(currentpos(:,3));
    xmax = max(currentpos(:,2));
    ymax = max(currentpos(:,3));
    xbins = ceil((xmax)/psize); %number of x
    ybins = ceil((ymax)/psize); %number of y
    xinc = (0:xbins)*psize; %makes a vectors of all the x values at each increment
    yinc = (0:ybins)*psize; %makes a vector of all the y values at each increment


    spikechart = normalizePosData(spikestochart, currentpos, dim);

    reshapesize = size(accpowerchart);
    %multiple linear regression of the responses in vector y on the predictors in matrix X.

    [b,bint,resid] = regress(spikechart(:),[velpowerchart(:), accpowerchart(:)]);
    chart = reshape(resid, reshapesize);

    %%%%%%%%%%%%%%%%%%%



    %smoothing spiking normalization
    sigma = 2; % two std deviations
    mask = fspecial('gauss', 1, sigma);
    chart = nanconv(chart, mask, 'same');

    %divided into 5cm by 5cm bins
    %place fields are 5 or more adjacent picels with a firing rate >3xmean unit rate
    %finds mean rate
    meanrate = nanmean(chart(:));
    maxrate = max(chart(:));
    chart(isnan(chart)) = 0;

    %finds maxes
    actualmax = imregionalmax(chart); %maxes are where there is a 1 on this chart
    [I,J] = find(actualmax==1);
    linearmax = sub2ind(size(actualmax), I, J); %linear indices

    %finds areas where firing > 3x mean. those are marked with a 1 on the chart
    chart;
    wanted = meanrate+(3*std(chart(:)));
    [I,J] = find(chart>=wanted);
    chartmax = zeros(size(chart));
    for p=1:length(I)
      chartmax(I(p),J(p)) = 1;
    end

    CC = bwconncomp(chartmax,4); %finds pixels connected by sides
    numfields = 0;
    fieldsize = [];
    centermax = [];
    centermean =[];


    for z=1:length(CC.PixelIdxList)
      if length(cell2mat(CC.PixelIdxList(z)))>=5 %this is a place field

        %find all instances where animal goes through place field

        %finds indices of place fields
        [centerY, centerX] = ind2sub(size(chartmax),cell2mat(CC.PixelIdxList(z)));
        %converts indices to actual values
        realX = (xmax)./xbins .* centerX;
        realY = (ymax)./ybins .* centerY;






        fieldsize(end+1) = length(cell2mat(CC.PixelIdxList(z)))*dim*dim;
        numfields = numfields+1;
        [centerY, centerX] = ind2sub(size(chartmax),cell2mat(CC.PixelIdxList(z)));

        xbins = ceil((xmax)/psize);
        ybins = ceil((ymax)/psize);


        newchart = zeros(size(chart));
        newchart(centerY, centerX) = chart(centerY, centerX);
        M = max(newchart, [], 'all');
        [centerYmax, centerXmax] = find(newchart==M);
        centerYmax = ybins-centerYmax; %here?
        newchart(find(newchart==0))=NaN;

        centerXmax = (xmax)./xbins * centerXmax;
        centerYmax = (ymax)./ybins * centerYmax;

        centerXmean = nanmean(centerX);
        centerYmean = nanmean(centerY);
        centerYmean = ybins-centerYmean;
        centerXmean = (xmax)./xbins * centerXmean;
        centerYmean = (ymax)./ybins * centerYmean;

        %The skewness was defined, in dimensionless units, as the ratio of the third
        %moment of the place field firing rate distribution divided by the cube of the
        %standard deviation (Spiegel 1994).

        xlimmin = [300 300  750 780 ];
        xlimmax = [505 505  950 950 ];
        ylimmin = [370 000  380 000 ];
        ylimmax = [700 370  700 380 ];


        for k=1:length(xlimmin)
          if centerYmean<380 & centerYmean>340 & size(newchart,2)>size(newchart,1)%center area so place field could go horizontally or vertically
                k=5;
                flattened = nanmean(newchart,1);
                newflattened = flattened;

              else
                inX = find(centerXmean > xlimmin(k) & centerXmean <=xlimmax(k)); %check to make sure correct indexing
                inY = find(centerYmean > ylimmin(k) & centerYmean <=ylimmax(k));
                inboth = intersect(inX, inY);
                if length(inboth)>0
                  flattened = nanmean(newchart,2)'; %need this directional
                  %need to flip right forced and left choice
                  if (k == 1 | k== 4)
                    newflattened = flattened;
                  elseif (k == 2 | k== 3)
                    newflattened = flip(flattened);
                  end
                end
              end
          end




        flatstart = (find(newflattened>0));
        newflattened = newflattened(flatstart(1):end);


        counter = 0;
        flatmean = 0;
        countersum = 0;

        for kk = 1:length(newflattened)
          if newflattened(kk)>0
          flatmean = flatmean+(kk*newflattened(kk));
          counter = counter+1;
          countersum = countersum+newflattened(kk);
          end
        end
        flatmean = flatmean./countersum;

        flatmom = 0;
        for kk = 1:length(newflattened)
          if newflattened(kk)>0
            kk-flatmean;
          flatmom = flatmom+((kk-flatmean)^3)*newflattened(kk);
          end
        end

        %flatmom = moment(flattened(~isnan(flattened)), 3);


        flatstd = 0;
        for kk = 1:length(newflattened)
          if newflattened(kk)>0
          flatstd = flatstd+((kk-flatmean)^2)*newflattened(kk);
        end
        end

        flatstd = sqrt(flatstd);

        if length(newflattened(~isnan(newflattened)))>2
          skewness = flatmom./(flatstd^3);
        else
          skewness = NaN;
        end

        %%%%%%%%%%%%%%%%
        %%here to find directional skewness, positive means skewed in the direction of travel


                        %   1   2   3   4   5
                        xlimmin = [300 300  750 780 ];
                        xlimmax = [505 505  950 950 ];
                        ylimmin = [370 000  380 000 ];
                        ylimmax = [700 370  700 380 ];
                %position 1: left forced
                %position 2: right forced
                %position 3: left choice arm
                %position 4: right choice arm
                %position 5: middle stem


                  toreward = [];
                  awayreward = [];
                  for k=1:length(xlimmin)
                    if centerYmean<380 & centerYmean>340 & size(newchart,2)>size(newchart,1)%center area so place field could go horizontally or vertically
                        k=5;
                        if currentdir == 1
                          newflattened = flattened;
                        elseif currentdir == 2
                          newflattened = flip(flattened);
                        end

              else
                inX = find(centerXmean > xlimmin(k) & centerXmean <=xlimmax(k)); %check to make sure correct indexing
                inY = find(centerYmean > ylimmin(k) & centerYmean <=ylimmax(k));
                inboth = intersect(inX, inY);
                if length(inboth)>0
                  flattened = nanmean(newchart,2)'; %need this directional
                  %need to flip right forced and left choice
                  if (k == 1 | k== 4)
                    if currentdir == 1
                      newflattened = flattened;
                    elseif currentdir == 2
                      newflattened = flip(flattened);
                    end
                  elseif (k == 2 | k== 3)
                    if currentdir == 1
                      newflattened = flip(flattened);
                    elseif currentdir == 2
                      newflattened = flattened;
                    end
                  end
                end
              end
          end


                  flatstart = (find(newflattened>0));
                  newflattened = newflattened(flatstart(1):end);




                  counter = 0;
                  flatmean = 0;
                  countersum = 0;


                  for kk = 1:length(newflattened)
                    if newflattened(kk)>0
                    flatmean = flatmean+(kk*newflattened(kk));
                    counter = counter+1;
                    countersum = countersum+newflattened(kk);
                    end
                  end
                  flatmean = flatmean./countersum;


                  flatmom = 0;
                  temp = [];
                  for kk = 1:length(newflattened)
                    if newflattened(kk)>0
                      kk-flatmean;
                      temp(end+1)= ((kk-flatmean)^3)*newflattened(kk);
                    flatmom = flatmom+((kk-flatmean)^3)*newflattened(kk);
                    end
                  end


                  %flatmom = moment(flattened(~isnan(flattened)), 3);

                  flatstd = 0;
                  for kk = 1:length(newflattened)
                    if newflattened(kk)>0
                    flatstd = flatstd+((kk-flatmean)^2)*newflattened(kk);
                  end
                  end

                  flatstd = sqrt(flatstd);

                  if length(newflattened(~isnan(newflattened)))>2
                    dirskewness = flatmom./(flatstd^3);
                  else
                    dirskewness = NaN;
                  end

                  %%%%%%%


        centermax(end+1:end+2) = [centerXmax(1), centerYmax(1)];
        centerXmean = (xmax)./xbins * centerXmean;
        centerYmean = (ymax)./ybins * centerYmean;
        centermean(end+1:end+2) = [centerXmean, centerYmean];


        allsizes(end+1) = fieldsize(end);
        allcenterXmean(end+1) = centerXmean;
        allcenterYmean(end+1) = centerYmean;
        allcenterXmax(end+1) = centerXmax(1);
        allcenterYmax(end+1) = centerYmax(1);
        allskew(end+1) = skewness;
        alldir(end+1) = currentdir;
        alldirskew(end+1) = dirskewness;

        if maxrate < .5
          numfields = NaN;
          fieldsize = NaN;
          allsizes(end+1) = NaN;
          allcenterXmean(end+1) = NaN;
          allcenterYmean(end+1) = NaN;
          allcenterXmax(end+1) = NaN;
          allcenterYmax(end+1) = NaN;
          allskew(end+1) = NaN;
          alldir(end+1) = currentdir;
          alldirskew(end+1) = NaN;
        end
        newdata = {name; clustsize; dir; alldir(end); allsizes(end); allcenterXmax(end); allcenterYmax(end); allskew(end); alldirskew(end)};
        output = horzcat(output, newdata);
      end



    end

    %maximum firing rate >= .5hz

    %newdata = {name; clustsize; dir; numfields; fieldsize; centermean; centermax; skewness};
    %output = horzcat(output, newdata);
  end

end
end

end

f = output';

allsizescenters = [alldir; allsizes; allcenterXmax; allcenterYmax; allskew; alldirskew]';
