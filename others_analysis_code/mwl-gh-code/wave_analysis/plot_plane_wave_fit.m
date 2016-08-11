function fig = plot_plane_wave_fit(theta_cdat,sample,xy_loc,theta,lambda,varargin)

p = inputParser;
p.addParamValue('mode','phase',@isstr);
p.parse(varargin{:});
opt = p.Results;

n_chans = size(theta_cdat.data,2);
samp_phases = theta_cdat.data(sample,:);

mean_phase = gh_circular_mean(samp_phases);

rel_phases = gh_circular_subtract(samp_phases,mean_phase);
rel_phases = samp_phases;
%rel_phase_big = repmat(rel_phases,[opt.samps_per_iteration,opt.samps_per_iteration,1]);

x_pos = xy_loc(:,1) - mean(xy_loc(:,1));
y_pos = xy_loc(:,2) - mean(xy_loc(:,2));

x = linspace(-3,3,50);
y = linspace(-3,3,50);

[XX,YY] = meshgrid(x,y);

dist_point_to_orig = sqrt(XX.^2 + YY.^2);
angles_from_orig = angle(XX + i.*YY);
total_angles = gh_circular_subtract(theta,angles_from_orig);

proj_dist = cos(total_angles) .* dist_point_to_orig;

if(strcmp(opt.mode,'raw'))
    ZZ = sin(proj_dist .* (2*pi) ./ lambda);
end
mid_phase = gh_circular_mean(rel_phases)
phase_offset = mid_phase; % + pi/2;
%phase_offset = 2.4;
phase_offset = 1.2964;
if(strcmp(opt.mode,'phase'))
    ZZ = mod((proj_dist)/lambda - phase_offset,2*pi) - pi;
end
ZZ(find(x == min(x)),find(y==min(y)))

fig = surf(XX,YY,ZZ);
xlabel('x');
ylabel('y');
hold on

dist_trode_to_orig = sqrt(x_pos.^2 + y_pos.^2);
angles_from_orig = angle(x_pos + i.*y_pos);
total_angles = gh_circular_subtract(theta,angles_from_orig);

proj_dist = cos(total_angles) .* dist_trode_to_orig;

if(strcmp(opt.mode,'raw'))
z_predicted = sin(proj_dist .* (2*pi) ./ lambda);
end
if(strcmp(opt.mode,'phase'))
    z_predicted = mod(proj_dist/lambda - phase_offset,2*pi) - pi;
end

plot3(x_pos,y_pos,z_predicted,'o','MarkerFaceColor',[0 0 0], 'MarkerSize',15);
plot3(x_pos,y_pos,rel_phases,'o','MarkerFaceColor',[0 1 0], 'MarkerSize',15);
hold off