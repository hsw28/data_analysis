function a = accel(file);

%computes acceleration. input a [2, #of points] vector, where first column is velcotiy, second is time
%
% returns acceleration per ms and time stamp vector
% doesn't smooth or transform-- do that later when you assign velocities


vel = file(1, :);
t = file(2, :);

accvector = [];
timevector = [];

s = size(t,2)

for i = 2:s
	vchange = vel(i)-vel(i-1);
	accel = vchange/(t(i)-t(i-1));
	accvector(end+1) = accel;
	timevector(end+1) = t(i);
end


a = [accvector; timevector];
