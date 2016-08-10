function bursts = rippleBursts(peakTimes, groupTimeThreshold)
% Take a list of ripple peak times, collect them by how many ripples
% in the burst.  One cell in top-level array for burst arity
% One cell in each top-level cell for each burst.

peakTimes = reshape(peakTimes,1,[]);

starts = [1, find( diff(peakTimes) > groupTimeThreshold == 1) + 1];
stops  = [find( diff(peakTimes) > groupTimeThreshold == 1), 1];

burstEnds = mat2cell( [starts; stops], 2, ones(1,numel(starts)) );
burstLengths = cellfun(@(x) (x(2)-x(1) + 1), burstEnds);

maxArity = 10;
bursts = cell(1,maxArity);

for a = 1:maxArity
    theseBursts = burstEnds( burstLengths == a );
    bursts{a} = cmap( @(x) peakTimes(x(1):x(2)), theseBursts );
end