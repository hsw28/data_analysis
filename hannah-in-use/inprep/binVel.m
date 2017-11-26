function thingy = binVel(time, accelORvel, t)
% Takes pos data, timestamps, cluster data, and window size (in seconds)
%outputs average firing rate per acceleration, with allerations binned as 0-10, 10-30, 30-60, 60-100, 100+ cm/s


if size(time, 2) < size(time, 1)
	time = time';
end

if size(accelORvel, 2) < size(accelORvel, 1)
	accelORvel = accelORvel';
end


start = min(time);
ending = max(time);


vbin = [0; 5; 10; 20; 50; 100];
vbin = [0; 6; 10; 15; 25; 100];


binvec = [];

acceldata = (assignvel(time,accelORvel));
length(acceldata);
sized = ceil(length(time)./(2000*t))-1;
avg_accel = zeros(sized,1);
for i = 1:sized
    avg_accel(i) = mean(acceldata((time > start+t*(i-1)) & (time < start+t*i))); % finds average vel within times
		if avg_accel(i) >= vbin(1) & avg_accel(i) <= vbin(2)
				binvec(end+1) = 1;
		elseif avg_accel(i) > vbin(2) & avg_accel(i) <= vbin(3)
				binvec(end+1) = 2;
		elseif avg_accel(i) > vbin(3) & avg_accel(i) <= vbin(4)
				binvec(end+1) = 3;
		elseif avg_accel(i) > vbin(4) & avg_accel(i) <= vbin(5)
					binvec(end+1) = 4;
		elseif avg_accel(i) > vbin(5) & avg_accel(i) <= vbin(6)
					binvec(end+1) = 5;
		elseif avg_accel(i) > vbin(6)
					binvec(end+1) = 6;
		end
end


thingy = binvec;
