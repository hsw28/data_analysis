function f = MASSnormalizePosData(spikestructure, posData, dim)

%just do one day at a time for now
%This function bins event data based on a user input bin size and
%normalizes based on total time spent in bin
%color maps with range based on highest and lowest three percent of firing
%Args:
%   eventData: A timeseries of cell firings (e.g. the output of abovetheta)
%   posData: The matrix of overall position data with columns [time,x,y]
%   dim: Bin size in cm (only square bins are supported)

spikenames = (fieldnames(spikestructure));
spikenum = length(spikenames);

for k = 1:spikenum
  spikename = char(spikenames(k));
  normalizePosData(spikestructure.(spikename), posData, dim);
  newName = strrep(spikename,'_',' ');
  title(['spike is ' newName ])
end
