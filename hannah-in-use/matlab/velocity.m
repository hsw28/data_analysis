function v = velocity(file1);

%computes velocity. input a [#ofpoints, 3] vector, where first column is time, second is x, third is y
% you can import your csv file as such:
% x = load('pos.csv');
% v = velocity(x);
%
% removes velocity outliers using a hempal filter
% returns velocities in cm/s and time stamp vector
%

file = file1';

t = file(1, :);
xpos = (file(2, :))';
xpos = lowpass4(xpos)';
ypos = (file(3, :))';
ypos = lowpass4(ypos)';
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




v = hampel(velvector, 30, 3);
v = [v/3.5; timevector];
