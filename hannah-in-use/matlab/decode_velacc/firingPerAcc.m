function thingy = firingPerAcc(time, accelORvel, firingdata, t)
% Takes pos data, timestamps, cluster data, and window size (in seconds)
% outputs average firing rate per velocity/acc
% ASSIGN VELOCITY BEFORE THIS FUNCTION

if size(time, 2) < size(time, 1)
	time = time';
end

if size(accelORvel, 2) < size(accelORvel, 1)
	accelORvel = accelORvel';
end

if size(accelORvel, 2) > size(firingdata, 1)
	firingdata = firingdata';
end

assvel = accelORvel;
%assvel = (assignvel(time,accelORvel));
time = time(1:length(assvel));



start = min(time);
ending = max(time);

r = mua_rate(firingdata,start,ending,t);
%info = thetaPowerVsTime(lfpdata,time,L,L);
rate = r(2,:); % number of spikes per time bin
size(rate);
fastest = max(rate);
m = length(rate);


avg_accel = zeros(m,1);
for i = 1:m
    avg_accel(i) = mean(assvel((time > start+t*(i-1)) & (time < start+t*i))); % finds average vel within times
end

avg_accel;

maxacc = max(avg_accel);
vbin = [-15; -7; -1; 1; 7; 15];



average = [];
deviation = zeros(fastest+1,1);
threshold = .01 * length(rate);


i = 0;
while i <= length(vbin)
		 if i==0
			 		subset = rate(avg_accel < vbin(1));

		 elseif i==length(vbin) %if you wanna go to infinity
						 subset = rate(avg_accel > vbin(i));

		 else
     			subset = rate(avg_accel > vbin(i) & avg_accel<=vbin(i+1));

		end

     if length(subset) < threshold
        average(i+1) = length(firingdata)./(length(time)./(2000*t)); %sub in average rate
     else
        average(i+1) = mean(subset);
     end
		 i = i+1;

end



thingy = [average];
