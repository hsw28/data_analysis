function thingy = firingPerVel(time, accelORvel, firingdata, t)
% Takes pos data, timestamps, cluster data, and window size (in seconds)

if size(time, 2) < size(time, 1)
	time = time';
end

if size(accelORvel, 2) < size(accelORvel, 1)
	accelORvel = accelORvel';
end

if size(accelORvel, 2) > size(firingdata, 1)
	firingdata = firingdata';
end

start = min(time);
ending = max(time);

r = mua_rate(firingdata,start,ending,t);
%info = thetaPowerVsTime(lfpdata,time,L,L);
rate = r(2,:); % number of spikes per time bin
fastest = max(rate);
m = length(rate);

acceldata = (assignvel(time,accelORvel));
length(acceldata);
length(time);
avg_accel = zeros(m,1);
for i = 1:m
    avg_accel(i) = mean(acceldata((time > start+t*(i-1)) & (time < start+t*i))); % finds average vel within times
end

maxacc = max(avg_accel);


vbin = [0; 10; 30; 60; 100];

average = [];
deviation = zeros(fastest+1,1);
threshold = .01 * length(rate);


i = 1;
while i <= length(vbin)
		 if i<length(vbin)
     			subset = rate(avg_accel > vbin(i) & avg_accel<vbin(i+1));
		 elseif i==length(vbin)
			 		subset = rate(avg_accel > vbin(i));
		 end
     if length(subset) < threshold
        average(i) = sum(rate)./length(time) %sub in average rate
     else
        average(i) = mean(subset);
     end
		 i = i+1;
end



thingy = [average];
