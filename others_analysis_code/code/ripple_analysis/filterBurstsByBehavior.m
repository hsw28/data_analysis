function fBursts = filterBurstsByBehavior(bursts, behavMap, behavString)

fBursts = bursts;

behavTimes = behavMap(behavString);
if(~iscell(behavTimes))
    behavTimes = {behavTimes};
end

for arity = 1:numel(bursts)
    thisBursts = bursts{arity};
    if(numel(thisBursts) > 0)
        burstInWindow = cellfun ( @(burst) gh_points_are_in_segs( burst{1}(1), behavTimes ), thisBursts );
        fBursts{arity} = thisBursts(burstInWindow);
    end
end