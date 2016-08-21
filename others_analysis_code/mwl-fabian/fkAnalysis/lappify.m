function result = lappify(segments, time, props)
%LAPPIIFY
%for a cell array of time vectors and a corresponding cell array of
%properties, this function will return a cell array of segments for each
%property for each time vector.

idx = applyfcn( @(t) select_idx(segments, t), [], time );

result = applyfcn( @(ii, pp) applyfcn( @(p) applyfcn( @(ix) p(ix,:), [], ii), [], pp ) , [], idx, props );



function idx = select_idx( segments, t)

[dummy, idx] = seg_select( segments, t );