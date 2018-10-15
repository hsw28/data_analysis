function thingy = binAcc(time, accelORvel, tdecode)
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

%good for 5 bins

%FIGURE THIS OUT
%vbin = [-15; -7; -1; 1; 7; 15];
assvel = abs(assvel);
vbin = [ 3; 6; 9; 12; 15; 18];




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

binmat = zeros(length(avg_accel), 1);
for k=0:length(vbin)
	if k==0
		index = find(avg_accel<vbin(k+1));
		binmat(index) = k+1;
	elseif k<length(vbin) & k>0
	index = find(avg_accel>=vbin(k) & avg_accel<vbin(k+1));
	binmat(index) = k+1;
	elseif k==length(vbin)
	index = find(avg_accel>=vbin(k));
	binmat(index) = k+1;
	end
end



thingy = [binmat'; avg_accel];
