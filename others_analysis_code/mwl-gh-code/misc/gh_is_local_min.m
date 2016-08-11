function local_max_bool = gh_is_local_min( values )
d = diff(values);
local_max_bool = [false, and( d(1:(end-1)) <= 0,...
    d(2:end) > 0), false];