function quick_combine_raster_cdat(sdat,cdat,varargin)

p = inputParser();
p.addParamValue('sdat_ind',1);
p.addParamValue('cdat_ind',1);
p.parse(varargin{:});

sdat = sdatslice(sdat,'index',p.Results.sdat_ind);
cdat = contchans(cdat,'chans',p.Results.cdat_ind);
timewin = [cdat.tstart, cdat.tend];
ax(1) = subplot(2,1,1);
sdat_raster(sdat,timewin)
ax(2) = subplot(2,1,2);
plot(conttimestamp(cdat),cdat.data);

linkaxes(ax,'x');