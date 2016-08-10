function dist_mat = simple_dists(sens_pos, source_pos)

n_sens = size(sens_pos,2);
n_source = size(source_pos,2);

% get euclidian distances in matrix size = [n_sens, n_source]
[SENS_X,SOURCE_X] = meshgrid( sens_pos(1,:), source_pos(1,:) );
[SENS_Y,SOURCE_Y] = meshgrid( sens_pos(2,:), source_pos(2,:) );

dist_mat = sqrt( (SENS_X - SOURCE_X).^2 + (SENS_Y - SOURCE_Y).^2 );