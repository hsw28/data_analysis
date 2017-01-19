function f = maxaccel(pos);

%takes position data and returns a matrix with times of positive and negative acceleration and accelerations
% returns entire duration of accelerations and not just max times
%output: f = [maxacc; eventtimes];


acc = accel(pos);
%first row is accel, second is time stamp
accl = acc(1,:);
ts = acc(2,:);

startpoints = [];
endpoints = [];
duration = [];
accmag = [];
numevents = 0;


for k = 1:(size(acc,2))
	if accl(k) > 200 | accl(k) <(-200)
		% we've found high acceleration or decelleration
		% looks to see when value returns to a low value, this is the start of the acc time
		i = k;
		while accl(i) > 200 | accl(i) < -200  && i>0
			i=i-1;
		end
		
		% looks to see when value returns this is the end of the acc time		
		j = k;
		while accl(j) > 200 | accl(j) < -200 && j<=(size(acc,2)-1)
			j=j+1;
		end

		%start time is d(i);
		%end time is d(j);
		k = j;		

		%only include events longer than 500ms
		if ts(j)-ts(i) > .5
			if ismember((i),startpoints)==0 && ismember((j),endpoints)==0 && ismember((j),endpoints)==0
				startpoints(end+1)=(i);
				endpoints(end+1)=(j);
			end
		end
	end
end

%for accel function first row is accel, second is time stamp
%make matrix
eventtimes = [];
maxacc = [];
n=1;
for n = 1:size(startpoints,2)
	a = ts(startpoints(n):endpoints(n));
	b = accl(startpoints(n):endpoints(n));
	eventtimes = cat(2, eventtimes, a);
	maxacc = cat(2, maxacc, b);
end

f = [maxacc; eventtimes];

