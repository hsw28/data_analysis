function f = MASSmutualinfo(posstructure, clusters, dim)


%determine how many spikes & pos files

bigXall = [];
bigYall = [];
MI= [];
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

  %Sum of (occprobs * mean firing rate per bin) * log2 (mean firing rate per bin / overall mean rate)
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

  chart = normalizePosData([1], posDataFast, 5);
  length(~isnan(chart(:))==1);


  if length(~isnan(chart(:))==1)>=1950
    for c = 1:(currentnumclust)
      name = char(currentclustname(c));
        clust = currentclusts.(name);
        [clustmin indexmin] = min(abs(posData(1,1)-clust));
        [clustmax indexmax] = min(abs(posData(end,1)-clust));
        clust = clust(indexmin:indexmax);



        assvel = assignvelOLD(clust, vel);
        fastspikeindex = find(assvel > velthreshold);
        %meanrate = length(fastspikeindex)./(totaltime); %WANT ONLY AT HIGH VEL
        clust = clust(fastspikeindex);

        fxmatrix = normalizePosData(clust,posDataFast,dim);
        fxmatrix = chartinterp(fxmatrix);
        fxmatrix = ndnanfilter(fxmatrix, 'gausswin', [10/dim, 10/dim], 2, {}, {'symmetric'}, 1);
  
        MI(end+1) = mutualinfo(fxmatrix);
      end
  else
    MI(end+1) = NaN;

  end

end

end


f = MI;
