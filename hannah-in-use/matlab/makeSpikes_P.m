function f = makeSpikes_P(posstructure, clusters)
%makes fake posisson units bases on inserted data

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
      if contains(name, date)==1 & cstart==0
        [currentclusts(:).(name)] = deal(clusters.(name));
      end
    end

    currentclustname = (fieldnames(currentclusts));
    currentnumclust = length(currentclustname);

    if currentnumclust>0
      tmin = posData(1,1);
      tmax = posData(end,1);
      time = tmin:1/2000:tmax;
      xvals = posData(:,2);
      yvals = posData(:,3);
      xmin = min(posData(:,2));
      ymin = min(posData(:,3));
      xmax = max(posData(:,2));
      ymax = max(posData(:,3));

      velthreshold = 12;
      vel = velocity(posData);
      vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
      fastvel = find(vel(1,:) > velthreshold);
      totaltime = length(fastvel)./30;
      posDataFast = posData(fastvel, :);
      xvalsFast = posDataFast(:,2);
      yvalsFast = posDataFast(:,3);

      for c = 1:(currentnumclust)
        name = char(currentclustname(c));
          clust = currentclusts.(name);
          [clustmin indexmin] = min(abs(posData(1,1)-clust));
          [clustmax indexmax] = min(abs(posData(end,1)-clust));
          clust = clust(indexmin:indexmax);

          %spikes = makeSpikes(timeStepS, spikesPerS, durationS, numTrains);


          train = makeSpikes(1/2000, length(clust)./(tmax-tmin), tmax-tmin);

          spikehere = find(train==1);
          spikehere = time(spikehere);
          f.(name) = spikehere;


        end

      end

    end
