function v = velocity(pos);
%computes velocity from position data as velocity(pos, varargin). if you put a 1 in varargin, velocity will be directional from junction of forced arms (380, 360)
%computes velocity. input a [#ofpoints, 3] vector, where first column is time, second is x, third is y
% you can import your csv file as such:
% x = load('pos.csv');
% v = noiselessVelocity(x);
%
% returns velocities in cm/s and time stamp vector
% Uses a discrete wavelet transform with a spline mother wavelet to compute
% numerical derivitive
% http://www.mathworks.com/matlabcentral/fileexchange/13948-numerical-differentiation-based-on-wavelet-transforms


file = pos';

t = file(1, :);
xpos = (file(2, :))';
%xpos = smoothdata(xpos,'gaussian',500);
%xpos = lowpass4(xpos)';
ypos = (file(3, :))';
%ypos = smoothdata(ypos,'gaussian',500);
%ypos = lowpass4(ypos)';
t = t(1:length(xpos));


velvector = [];
timevector = [];

s = size(t,2);

for i = 2:s-1
	%find distance travelled
	if t(i)~=t(i-1)
		hypo = hypot((xpos(i-1)-xpos(i+1)), (ypos(i-1)-ypos(i+1)));
		vel = hypo./((t(i+1)-t(i-1)));
		velvector(end+1) = vel;
		timevector(end+1) = t(i);
	end
end



%v = hampel(velvector, 30, 3);
v = smoothdata(velvector,'gaussian',500);
v = v(1:length(timevector));
v = [(v/3.5); timevector];
