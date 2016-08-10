function [m2_sens_pos, m2_sens_pickup, m2_source_pos, m2_source_strength] = ...
    simple_neighbor(m_sens_pos, m_sens_pickup, m_source_pos, m_source_strength,signals_mat,T)

% parameters
step_frac = 0.1;
n_sens = size(m_sens_pos,2);
n_source = size(m_source_pos,2);

SENS_X = repmat(m_sens_pos(1,:),n_source,1);
SENS_Y = repmat(m_sens_pos(2,:),n_source,1);
SOURCE_X = repmat(m_source_pos(1,:)',1,n_sens);
SOURCE_Y = repmat(m_source_pos(2,:)',1,n_sens);
x_dists = SOURCE_X - SENS_X;
y_dists = SOURCE_Y - SENS_Y;
dists = sqrt( x_dists .^2 + y_dists .^2);

% unit vectors pointing from sens toward source
x_dists_unit_vec = x_dists ./ dists;
y_dists_unit_vec = y_dists ./ dists;

dist_targets = 1./sqrt(signals_mat);  % because str = 1/(r^2)
dist_offs = dists - dist_targets;



sens_dx = step_frac * sum(x_dists_unit_vec .* dist_offs,1)./30 + T*randn(1,n_sens);
sens_dy = step_frac * sum(y_dists_unit_vec .* dist_offs,1)./30 + T*randn(1,n_sens);
source_dx = -step_frac * sum(x_dists_unit_vec .* dist_offs,2) + T*randn(n_source,1);
source_dy = -step_frac * sum(y_dists_unit_vec .* dist_offs,2) + T*randn(n_source,1);

sens_dx = zeros(size(sens_dx));
sens_dy = zeros(size(sens_dy));

sens_move_bool = rand(size(sens_dx)) < 1/numel(sens_dx);
source_move_bool = rand(size(source_dx)) < 1/numel(source_dx);

source_move_ind = ceil(n_source*rand(1));
source_move_bool = zeros(size(sens_move_bool));
source_move_bool(source_move_ind) = 1;
m = source_move_ind;

for n = 1:n_sens
    plot([m_sens_pos(1,n), m_source_pos(1,m)], [m_sens_pos(2,n), m_source_pos(2,m)],'-'); hold on;
    target = dist_targets(m,n);
    this_dist = dists(m,n);
    text( mean( [ m_sens_pos(1,n), m_source_pos(1,m) ]), mean([ m_sens_pos(2,n), m_source_pos(2,m) ]), [num2str(this_dist),'(',num2str(target),')']);
end

m2_sens_pos = [m_sens_pos(1,:) + sens_dx.*sens_move_bool;...
    m_sens_pos(2,:) + sens_dy.*sens_move_bool];

m2_source_pos = [m_source_pos(1,:) + (source_dx.*source_move_bool)'; ...
    m_source_pos(2,:) + (source_dy.*source_move_bool)'];

m2_sens_pickup = m_sens_pickup;

m2_source_strength = m_source_strength;