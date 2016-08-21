

set = setIdxTrip{2};
rip = ripples(2);

events = [];
for i = 1:numel(set)
    tmp = rip.peakIdx - rip.peakIdx(set(i));
    tmp = tmp(tmp<1500 & tmp>0);
    events = [events; tmp];
end
%%