function the_plot = quick_time_plot(sdat,timewin)

nclust = numel(sdat.clust);

figure;

for i = 1:nclust
    spikes = sdat.clust{i}.stimes;
    spikes = spikes(and((spikes > min(timewin)),(spikes < max(timewin))));
    %nspike = numel(spikes);
    x = ones(size(spikes)).*sdat.clust{i}.mlloc;
    %xsize = size(x)
    y = ones(size(spikes)).*sdat.clust{i}.aploc;
    %ysize = size(y)
    z = spikes;
    %zsize = size(z)
    the_plot = plot3(x,y,z,'.');
    hold on
end