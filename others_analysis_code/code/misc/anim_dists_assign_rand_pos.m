function pos = anim_dists_assign_rand_pos(n_points,floor_size)

pos = real(floor_size/2)*rand(1,n_points) +...
    i * imag(floor_size/2) * rand(1,n_points) + floor_size*1/4;

