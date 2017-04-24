function v = noiselessVelocity(file1)

%computes velocity. input a [#ofpoints, 3] vector, where first column is time, second is x, third is y
% you can import your csv file as such:
% x = load('pos.csv');
% v = noiselessVelocity(x);
%
% returns velocities in cm/s and time stamp vector
% Uses a discrete wavelet transform with a spline mother wavelet to compute
% numerical derivitive
% http://www.mathworks.com/matlabcentral/fileexchange/13948-numerical-differentiation-based-on-wavelet-transforms

file = file1';

t = file(1, :);
xpos = file(2, :);
ypos = file(3, :);

xderiv = derivative_dwt(xpos,'spl',5,1/30,1); % The third arg is the detail coefficient. Make it higher to smooth more, make it lower to capture more noise
yderiv = derivative_dwt(ypos,'spl',5,1/30,1); % detail coefficient of 5 was chosen expirmentally to achieve best fitting without oversmoothing
velvector = hypot(xderiv,yderiv)/3.5; % computes magnitude of velocity and converts to cm/s

v = [velvector; t];