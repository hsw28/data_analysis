function [values probs] = decodeshitVelstruct(timevector, clustersSTRUCT, vel, tdecode, t, str)

    name = convertStringsToChars(str);
    % get date of spike
    date = strsplit(name,'date_'); %splitting at year rat12_2018_08_20_time
    date = char(date(1,2));
    date = strsplit(date,'_time'); %rat12_2018_08_20
    date = char(date(1,1));
    % formats date to be same as in cluster structure: cluster_rat6_2017_04_27_26_maze_cl_2
    clustformat = strcat('cluster_', date); %cluster_rat12_2018_08_20

    actualseconds = length(timevector) / 2000;
    fakeseconds = timevector(end)-timevector(1);
    conversion = actualseconds/fakeseconds;
    if abs(conversion-1)<.05
      conversion = 1;
    end

clustspikenames = (fieldnames(clustersSTRUCT));
spikenum = length(clustspikenames);


for k = 1:(spikenum)
  name = char(clustspikenames(k));
  if contains(name, clustformat)==1
    clusters.(name) = clustersSTRUCT.(name)*conversion;
  end
end

timevector = timevector*conversion;
vel(2,:) = vel(2,:)*conversion;

[values probs] = decodeshitVel(timevector, clusters, vel, tdecode, t);
