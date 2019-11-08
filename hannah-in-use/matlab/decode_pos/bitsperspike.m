function f = bitsperspike(posstructure, clusters, dim)
%outputs name, bits per spike, and mean firing rate normalized by position

%determine how many spikes & pos files
tic

bigXall = [];
bigYall = [];
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

output = {'cluster name'; 'bits/spike'; 'mean rate'};

for z = 1:length(pnames)
  currentname = char(pnames(z));
  posData = posstructure.(currentname);

  cstart = 0;
  cend = 100000000;



  posData = fixpos(posData);
  % get date of spike
  date = strsplit(currentname,'date_'); %splitting at year rat12_2018_08_20_time
  date = char(date(1,2));
  date = strsplit(date,'_position'); %rat12_2018_08_20
  date = char(date(1,1));

  currentclusts = struct;
  for c = 1:(spikenum)
    name = char(clustspikenames(c));
    if contains(name, date)==1 & cstart==0
      [currentclusts(:).(name)] = deal(clusters.(name));
    end
  end

  currentclustname = (fieldnames(currentclusts));
  currentnumclust = length(currentclustname);

  if currentnumclust>0

  %Sum of (occprobs * mean firing rate per bin / overall mean rate) * log2 (mean firing rate per bin / overall mean rate)
  psize = 3.5 * dim;
  xvals = posData(:,2);
  yvals = posData(:,3);
  xmin = min(posData(:,2));
  ymin = min(posData(:,3));
  xmax = max(posData(:,2));
  ymax = max(posData(:,3));


  xbins = ceil((xmax-xmin)/psize); %number of x
  ybins = ceil((ymax-ymin)/psize); %number of y


  xinc = xmin +(0:xbins)*psize; %makes a vectors of all the x values at each increment
  yinc = ymin +(0:ybins)*psize; %makes a vector of all the y values at each increment

  velthreshold = 12;
  vel = velocity(posData);
  vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
  fastvel = find(vel(1,:) > velthreshold);
  totaltime = length(fastvel)./30;
  posDataFast = posData(fastvel, :);
  xvalsFast = posDataFast(:,2);
  yvalsFast = posDataFast(:,3);

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
occprobs = chartinterp(occprobs);

%Sum of (occprobs * mean firing rate per bin / meanrate) * log2 (mean firing rate per bin / meanrate)

%spike rates
cnames = {};




fxmatrix = firingPerPos(posData, currentclusts, dim, 1, 30, occ);


for c = 1:(currentnumclust)
  name = char(currentclustname(c));
    clust = currentclusts.(name);
    [clustmin indexmin] = min(abs(posData(1,1)-clust));
    [clustmax indexmax] = min(abs(posData(end,1)-clust));
    clust = clust(indexmin:indexmax);

    assvel = assignvelOLD(clust, vel);
    fastspikeindex = find(assvel > velthreshold);
    %meanrate = length(fastspikeindex)./(totaltime); %WANT ONLY AT HIGH VEL


    fxclust = fxmatrix.(name);
    fxclust = chartinterp(fxclust);
    meanrate = nanmean(fxclust(:));
    fxclust = ndnanfilter(fxclust, 'gausswin', [10/dim, 10/dim], 2, {}, {'symmetric'}, 1);

    neg = find(fxclust(:)<0);
    fxclust(neg) = eps;


    oldbits = 0;
    newbits = 0;
    bitsper = 0;
    bigX = 0;
    bigY = 0;
    for x = (1:xbins) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
      for y = (1:ybins)
        if occprobs(x,y)>0 & ~isnan(fxclust(x,y))==1 & ~isnan(occprobs(x,y))==1


        newbits = (occprobs(x,y) .* (fxclust(x,y) ./ meanrate) * log2((fxclust(x,y) ./ meanrate)));
      %  if newbits>5
      %    x
      %    y
      %  end

        bitsper = bitsper + newbits; %if you want per location, assign this to a matrix


        if newbits > oldbits
          oldbits = newbits;

          xbins = ceil((xmax-xmin)/psize);
          ybins = ceil((ymax-ymin)/psize);

          bigX = (xmax-xmin)./xbins * x + xmin;
          bigY = (ymax-ymin)./ybins * y + ymin;
        end



        end
      end
    end


    bigXall = [bigXall, bigX];
    bigYall = [bigYall, bigY];
    if meanrate <.05
      bitsper = NaN;
    end
    newdata = {name; bitsper; meanrate};

    output = horzcat(output, newdata);

end
end

end


f = output';
