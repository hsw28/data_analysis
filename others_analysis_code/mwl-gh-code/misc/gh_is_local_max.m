function local_max_bool = gh_is_local_max( values )
d = diff(values);
local_max_bool = [0, and( d(1:(end-1)) >= 0,...
    d(2:end) < 0), 0];