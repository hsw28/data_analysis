function [lambda_mu,theta_mu,lambda_var,theta_var] = plane_wave_params(theta_cdat,sample,xy_loc,varargin)
% xy_loc should be size n_chans_by_2.  Column 1 is x, column 2 is y

p = inputParser;
p.addParamValue('iterations',2,@isreal);
p.addParamValue('samps_per_iteration',100,@isreal);
p.addParamValue('mode','phase',@isstr);
p.parse(varargin{:});
opt = p.Results;

n_chans = size(theta_cdat.data,2);
samp_phases = theta_cdat.data(sample,:);

mean_phase = gh_circular_mean(samp_phases);

rel_phases = reshape(gh_circular_subtract(samp_phases,mean_phase),1,1,n_chans);
rel_phase_big = repmat(rel_phases,[opt.samps_per_iteration,opt.samps_per_iteration,1]);

x_pos = xy_loc(:,1) - mean(xy_loc(:,1));
y_pos = xy_loc(:,2) - mean(xy_loc(:,2));

x_pos_big = repmat(reshape(x_pos,[1,1,n_chans]),[opt.samps_per_iteration,opt.samps_per_iteration,1]);
y_pos_big = repmat(reshape(y_pos,[1,1,n_chans]),[opt.samps_per_iteration,opt.samps_per_iteration,1]);

theta_test = linspace(-pi,pi,opt.samps_per_iteration);
%theta_test = linspace(-0.8,-0.7,opt.samps_per_iteration);

lambda_test = linspace(0.1,20,opt.samps_per_iteration);

theta_test_x = repmat(theta_test',[1,opt.samps_per_iteration,n_chans]);
lambda_test_y = repmat(lambda_test,[opt.samps_per_iteration,1,n_chans]);

angle_orig_to_theta = theta_test_x;
angle_orig_to_trode = angle(x_pos_big + i.* y_pos_big);
trode_dist_from_origin = sqrt(y_pos_big.^2 + x_pos_big.^2);
total_angle = gh_circular_subtract(angle_orig_to_trode, angle_orig_to_theta);
projection_length = trode_dist_from_origin .* cos(total_angle);

if(strcmp(opt.mode,'raw'))
    V_predicted = sin(projection_length .* (2*pi) ./ lambda_test_y);
end
if(strcmp(opt.mode,'phase'))
    V_predicted = mod(projection_length,2*pi);
end

SS = sum(((V_predicted - rel_phase_big).^2),3);

surf(theta_test_x(:,:,1),lambda_test_y(:,:,1),SS);