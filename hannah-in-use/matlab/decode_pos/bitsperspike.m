function f = bitsperspike(posstructure, clusters, dim, tdecode)


%determine how many spikes & pos files


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

output = {'cluster name'; 'bits/spike'};

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

fxmatrix = firingPerPos(posData, currentclusts, dim, tdecode, 30);

for c = 1:(currentnumclust)
  name = char(currentclustname(c));
    clust = currentclusts.(name);
    [clustmin indexmin] = min(abs(posData(1,1)-clust));
    [clustmax indexmax] = min(abs(posData(end,1)-clust));
    clust = clust(indexmin:indexmax);

    assvel = assignvelOLD(clust, vel);
    fastspikeindex = find(assvel > velthreshold);
    meanrate = length(fastspikeindex)./(totaltime); %WANT ONLY AT HIGH VEL

    fxclust = fxmatrix.(name);

    bitsper = 0;
    for x = (1:xbins) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
      for y = (1:ybins)
        if occprobs(x,y)>0 & ~isnan(fxclust(x,y))==1

        bitsper = bitsper + (occprobs(x,y) .* (fxclust(x,y) ./ meanrate) * log2((fxclust(x,y) ./ meanrate))); %if you want per location, assign this to a matrix

        end
      end
    end

    newdata = {name; bitsper};

    output = horzcat(output, newdata);

end
end

end

f = output';
