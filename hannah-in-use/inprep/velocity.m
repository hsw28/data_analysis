function v = velocity(file);

time = file(1, :)
xpos = file(2, :)
ypos = file(3, :)
velvector = []

for i = 2:size(time)
	hypo = hypot(xpos(i), ypos(i));
	vel = hypo./(time(i)-time(i-1));
	velvector(end+1) = vel;
end

v = velvector
	
