function mua = jp_calc_mu_rate(mua, et, dt)

if nargin==2
    dt = .01;
end

tbins = et(1)-dt:dt:et(2)+dt;

for iClust = 1:mua.nclust

    rate = hist(mua.clust{iClust}.stimes, tbins) ./ dt;
    rate = rate(2:end-1);
    mua.clust{iClust}.rate = rate;
    mua.clust{iClust}.time_limits = et;
    mua.clust{iClust}.fs = 1/dt;
    
    if ~exist('globalRate', 'var')
        globalRate = rate;
    else
        globalRate = globalRate+rate;
    end

end

mua.rate = globalRate ./ mua.nclust;
mua.timestamps = tbins(2:end-1);
mua.fs = 1/dt;
