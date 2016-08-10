function [local_max_inds, local_min_inds, down_crossing_inds, up_crossing_inds] = gamma_find_extremes(sdat)

ts = conttimestamp(sdat);
data = sdat.data;

d1 = diff(sdat.data);

local_max_inds = find(and(d1(2:end) < 0, d1(1:end-1) > 0)) + 1;
local_min_inds = find(and(d1(2:end) > 0, d1(1:end-1) < 0)) + 1;

down_crossing_inds = find(and(data(2:end) < 0, data(1:end-1) > 0));
up_crossing_inds = find(and(data(2:end) > 0, data(1:end-1) < 0));
