function bin_centers = bin_edges_to_centers(bin_edges)

% determine the spacing of each bin
dt = bin_edges(2) - bin_edges(1);

% bin centers will start half a bin after the first edge,
% and end half a bin before the last edge,
% there will be one fewer center than there are edges

bin_centers = linspace( bin_edges(1)   + dt/2, ...
                        bin_edges(end) - dt/2, ...
                        numel(bin_edges) - 1 );