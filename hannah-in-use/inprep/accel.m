function a = accel(file);

%computes acceleration. input a [#ofpoints, 3] position vector, where first column is time, second is x, third is y
%
% returns acceleration per ms and time stamp vector where first row is accel, second is time stamp
% doesn't smooth or transform-- do that later when you assign velocities

v = velocity(file);

vel = v(1, :);
t = v(2, :);

accvector = [];
timevector = [];

s = size(t,2);

for i = 3:s-2
	vchange = vel(i+2)-vel(i-2);
	accel = vchange/(t(i+2)-t(i-2));
	accvector(end+1) = accel;
	timevector(end+1) = t(i);
end

accvector = smooth(accvector);
a = [accvector'; timevector];
