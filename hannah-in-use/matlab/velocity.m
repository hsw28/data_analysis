function v = velocity(file1);

%computes velocity. input a [#ofpoints, 3] vector, where first column is time, second is x, third is y
% you can import your csv file as such:
% x = load('pos.csv');
% v = velocity(x);
%
% returns velocities per ms and time stamp vector
% doesn't smooth or transform-- do that later when you assign velocities

file = file1';

t = file(1, :);
xpos = file(2, :);
ypos = file(3, :);

velvector = [];
timevector = [];

s = size(t,2);

for i = 2:s
	%find distance travelled
	hypo = hypot(xpos(i), ypos(i));
	vel = hypo./((t(i)-t(i-1)));
	velvector(end+1) = vel;
	timevector(end+1) = t(i);
end



v = [velvector; timevector];

	
