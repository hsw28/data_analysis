function bin_edges = bin_centers_to_edges(bin_centers)

% how far apart are the bin centers?
dt = bin_centers(2) - bin_centers(1);

% the edges will start half a bin width before the first bin,
% and end half a bin width after the last bin
% there will be one more edge than there are centers
%
% (edge)  center (edge) center (edge)

bin_edges = linspace( bin_centers(1)   - dt/2, ...
                      bin_centers(end) + dt/2, ...
                      numel(bin_centers) + 1 );