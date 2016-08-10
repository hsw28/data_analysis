function cdat = mkratecont(sdat,varargin)

% To start, I'll assume rate_by_time is already attached to each clust

nclust = numel(sdat.clust);

cdat = sdat.clust{1}.rate_by_time;
min_time = NaN;
max_time = NaN;

for i = 1:nclust
    min_time = max([min_time, sdat.clust{i}.rate_by_time.tstart]);
    max_time = min([max_time, sdat.clust{i}.rate_by_time.tend]);
end

cdat = sdat.clust{i}.rate_by_time;
for i = 2:nclust
    tmp_cdat = contwin(sdat.clust{i}.rate_by_time,[min_time,max_time]);
    cdat = contcombine(cdat,tmp_cdat);
end

return

% TODO: Pass channel names along in a safe way.