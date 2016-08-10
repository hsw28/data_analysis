function cdat = theta_from_mua(mua_list,timewin)


sdat = immua(mua_list,'timewin',timewin);

[~,cdat] = assign_rate_by_time(sdat,'samplerate',400);

cdat.data = mean( zscore(cdat.data), 2);
cdat.chanlabels = {'mua_mean'};

%cdat.data = mean(cdat.data,2);

