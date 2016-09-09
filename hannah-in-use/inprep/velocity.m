function v = velocity(file1);

%computes velocity. input a [3,#ofpoints] vector, where first column is time, second is x, third is y
% returns velocities per ms and time stamp vector
% smooths velocities and does hilbert filtering

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

#transforms
hil = abs(hilbert(velvector);

#smooths with moving average, window 3
velo = smooth(hil,3);

v = [velo'; timevector];

	
