function thingy = firingPerAcc(time, accelORvel, firingdata, t, vbin, avg_accel)
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



mintime = accelORvel(2,1);
maxtime = accelORvel(2,end);



[c indexmin] = (min(abs(firingdata-mintime)));
[c indexmax] = (min(abs(firingdata-maxtime)));
firingdata = firingdata(indexmin:indexmax);

%%FOR TROUBLESHOOTING
%[c indexmin] = (min(abs(time-mintime)));
%[c indexmax] = (min(abs(time-maxtime)));
%time = time(indexmin:indexmax);
%assvel = assignvel(time, accelORvel);
%asstime = assvel(2,:);


assvel = accelORvel;


%time = time(indexmin:indexmax);

assvel = assvel(1,:);



start = min(time);
ending = max(time);


r = mua_rate(firingdata,start,ending,t);
%info = thetaPowerVsTime(lfpdata,time,L,L);
rate = r(2,:); % number of spikes per time bin
fastest = max(rate);
m = length(rate);


maxacc = max(avg_accel);



average = [];
deviation = zeros(fastest+1,1);
threshold = .01 * length(rate);


i = 0;
while i <= length(vbin)
		 if i==0
			 		subset = rate(avg_accel < vbin(1));
		 elseif i==length(vbin) %if you wanna go to infinity
						 subset = rate(avg_accel >= vbin(i));
		 else

     		subset = rate(avg_accel >=vbin(i) & avg_accel<vbin(i+1));


		end

%     if length(subset) < threshold
%        average(i+1) = length(firingdata)./(length(time)./(2000*t)); %sub in average rate
%     else
        average(i+1) = mean(subset);
%     end

		 i = i+1;

end



thingy = [average];
