function thingy = binVel(time, accelORvel, tdecode)
% for use with decode shit. bins actual velocities in same bins as decode shit, so you can compare your decoded data


if size(time, 2) < size(time, 1)
	time = time';
end

if size(accelORvel, 2) < size(accelORvel, 1)
	accelORvel = accelORvel';
end


mintime = accelORvel(2,1);
maxtime = accelORvel(2,end);

[c indexmin] = (min(abs(time-mintime)));
[c indexmax] = (min(abs(time-maxtime)));
time = time(indexmin:indexmax);

assvel = (assignvel(time,accelORvel));
assvel = assvel(1,:);

vbin = [0; 7; 14; 21; 28; 35]


tm = 1;
tdecodesec = tdecode;
tdecode = tdecode*2000;
avg_accel = []
while tm <= length(time)-(rem(length(time), tdecode)) & (tm+tdecode) < length(time)
    avg_accel(end+1) = mean(assvel(tm:tm+tdecode));
		        if tdecodesec>=.25
		          tm = tm+(tdecode/2);
		        else
		          tm = tm+tdecode;
		        end
end


for k=1:length(vbin)
	if k<length(vbin)
	index = find(avg_accel>=vbin(k) & avg_accel<vbin(k+1));
	avg_accel(index) = k;
	elseif k==length(vbin)
	index = find(avg_accel>vbin(k));
	avg_accel(index) = k;
	end
end




thingy = avg_accel;
