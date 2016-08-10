function b = gh_points_are_in_segs( pts, segs )

b = zeros(size(pts));

if(~iscell(segs))
    segs = mat2cell(segs, ones(size(segs,1),1), 2);
end

for n = 1:numel(segs)
    b( pts >= min(segs{n}) & pts <= (max(segs{n})) ) = 1;
end

b = logical(b);