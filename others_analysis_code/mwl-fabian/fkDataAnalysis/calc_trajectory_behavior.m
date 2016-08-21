function [linpos, linvelocity] = calc_trajectory_behavior(trajectory, pos)

Fs_tracker = 30;

%create smoothing kernel
sd = 0.5; %standard deviation of gaussian kernel in seconds
x = [-4*sd:1./Fs_tracker:4*sd]';
kernel = normpdf( x, 0, sd );
kernel = kernel ./ sum(kernel);

%linearize position
linpos = trajectory.linearize( pos.headpos );

%calculate linearized velocity
linvelocity = conv2( gradient( linpos, 1./Fs_tracker ), kernel, 'same');
