function v = velocity(file);

%computes velocity. input a [3,#ofpoints] vector, where first column is time, second is x, third is y
% returns velocities per ms

t = file(1, :);
xpos = file(2, :);
ypos = file(3, :);
velvector = [0];

s = size(t,2)

for i = 2:s
	%find distance travelled
	hypo = hypot(xpos(i), ypos(i));
	vel = hypo./((t(i)-t(i-1)./10000));
	velvector(end+1) = vel;
end



v = smooth(velvector);
	
