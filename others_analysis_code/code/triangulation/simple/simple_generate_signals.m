function [signals_mat] = simple_generate_signals(dist_mat, sens_pickup, source_strength)

% get matrix of source strength * sensor pickup
strength_prod = sens_pickup' * source_strength;

% signal amplitude matrix, by the 1/r^2 rule
% hack - the last transpose operator.  Check col/row meanings!
signals_mat = 1./(dist_mat.^2) .* strength_prod';