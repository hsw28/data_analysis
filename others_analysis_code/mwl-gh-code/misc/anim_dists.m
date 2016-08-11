function h = anim_dists(pref_mat, varargin)

p = inputParser();
p.addParamValue('floor_size',[2 + 2i]);
p.addParamValue('mass',0.02);
p.addParamValue('dt',0.1);
p.addParamValue('total_time',0.5);
p.addParamValue('debug',true);
p.addParamValue('repeat_x',4);
p.addParamValue('repeat_y',4);
p.parse(varargin{:});

n_points = size(pref_mat,1);

for a = 1:p.Results.repeat_x
    for b = 1:p.Results.repeat_y
        
        subplot(p.Results.repeat_x,p.Results.repeat_y, (a-1)*(p.Results.repeat_x) + b);

pos = anim_dists_assign_rand_pos(n_points,p.Results.floor_size);
strains_mat = anim_dists_calc_strains(pos,pref_mat);

h = rectangle('Position', [0 0 real(p.Results.floor_size), imag(p.Results.floor_size)]);

for n = [0:p.Results.dt:p.Results.total_time]
    anim_dists_draw(h, pos, pref_mat, strains_mat, p.Results.floor_size);
    pause(p.Results.dt)
    strains_mat = anim_dists_calc_strains(pos,pref_mat);
    pos = pos + sum(strains_mat,1).*1/10;
    hold off
end

    end
end