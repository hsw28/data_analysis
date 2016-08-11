function r = gh_event_rate_in_segments(events,segs)

tTotal = mapReduce( 0, @diff, @(x,y) x+y, segs );

nEvents = sum(gh_points_are_in_segs(events,segs));

r = nEvents/tTotal;