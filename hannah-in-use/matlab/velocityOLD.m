function v = velocity(pos, varargin);

%computes velocity from position data as velocity(pos, varargin). if you put a 1 in varargin, velocity will be directional from junction of forced arms (380, 360)
% you can import your csv file as such:
% x = load('pos.csv');
% v = velocity(x);
%
% smooths velocity with a 250gaussian window
% returns velocities in cm/s and time stamp vector
%

file = pos';

t = file(1, :);
xpos = (file(2, :))';
%xpos = lowpass4(xpos)';
ypos = (file(3, :))';
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

%250ms gaussian window
%v = smoothdata(velvector, 'gaussian', 500);
v = hampel(velvector, 10, 3); %OLD WAY
v = [v/3.5; timevector];
