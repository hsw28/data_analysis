function s = gh_invert_segs(in_s)

s = cellfun( @(x,y) [x(2), y(1)], ...
    in_s(1:(end-1)), in_s(2:end), 'UniformOutput',false);