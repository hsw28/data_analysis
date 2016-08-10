function newSegs = gh_subtract_segs(s1,s2)
% segs1 - segs2

newSegs = gh_intersection_segs(s1, gh_invert_segs(s2));