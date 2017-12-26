function thingy = binAcc(time, accelORvel, t)
% for use with decode shit. bins actual velocities in same bins as decode shit, so you can compare your decoded data


if size(time, 2) < size(time, 1)
	time = time';
end

if size(accelORvel, 2) < size(accelORvel, 1)
	accelORvel = accelORvel';
end


start = min(time);
ending = max(time);

binvec = [];

assvel = (assignvel(time,accelORvel));

%good for 5 bins

vbin = [-5; -1; 1; 5];

sized = ceil(length(assvel)./(2000*t))-1; %done in time stamps. number of bins
avg_accel = zeros(sized,1);
t = t*2000;
for i = 1:(sized)

		time(1+t*(i-1));
		time(1+t*i);
    avg_accel(i) = mean(assvel((time > time(1+t*(i-1)) & (time < time(1+t*i))))); % finds average vel within times
		if avg_accel(i) <= vbin(1)
				binvec(end+1) = 1;
		elseif avg_accel(i) > vbin(1) & avg_accel(i) <= vbin(2)
					binvec(end+1) = 2;
		elseif avg_accel(i) > vbin(2) & avg_accel(i) <= vbin(3)
			binvec(end+1) = 3;
		elseif avg_accel(i) > vbin(3) & avg_accel(i) <= vbin(4)
				binvec(end+1) = 4;
		%elseif avg_accel(i) > vbin(4) & avg_accel(i) <= vbin(5)
		%			binvec(end+1) = 5;
		%elseif avg_accel(i) > vbin(5) & avg_accel(i) <= vbin(6)
		%			binvec(end+1) = 6;
		%elseif avg_accel(i) > vbin(6) & avg_accel(i) <= vbin(7) %to not go to infinity
		%					binvec(end+1) = 6;
		elseif avg_accel(i) > vbin(end)
				binvec(end+1) = 5; %CAN CHANGE but use it to go to infifnity
		else
			  binvec(end+1) = 100;

		end
end


thingy = binvec;
