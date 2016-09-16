function f = lfp_acc(lfpdata, lfptimestamp, pos);

% takes lfp data and position as inputs and finds time with fast accelleration/decelleration
% returns a plot with LFPs plotted during accell/decell and accell and decell plotted along side it
% ex
% lfp_acc(lfp.data, lfp.timestamp, pos);


c=lfpdata;
d=lfptimestamp;

acc = accel(pos);
acc = assignvel(lfptimestamp, acc);

startpoints = [];
endpoints = [];
duration = [];
accmag = [];
numevents = 0;


for k = 1:(size(acc,2))
	if acc(k) > 50 || acc(k) < -50
		% we've found high acceleration or decelleration
		% looks to see when value returns to a low value, this is the start of the acc time
		i = k;
		while acc(i) > 50 || acc(i) < -50  && i>0
			i=i-1;
		end
		
		% looks to see when value returns this is the end of the acc time		
		j = k;
		while acc(j) > 50 || acc(j) < -50 && j<=(size(acc,2))
			j=j+1;
		end

		%start time is d(i);
		%end time is d(j);
		k = j;		

		%only include events longer than 30ms
		if d(j)-d(i) > .03
			if ismember((i-10),endpoints)==0 && ismember((j+10),endpoints)==0
				numevents = numevents+1;
				%making a vector with start and end indices, with a ~60ms buffer around (equal to 7 time points)
				startpoints(end+1)=(i-10);
				endpoints(end+1)=(j+10);
				duration(end+1)=(d(j+10)-d(i-10));
				accmag(end+1) = mean(acc(i):acc(j));
			end
		end
	end
end

%sort points by magnitude of acceleration
allpoints = [startpoints;endpoints;duration;accmag];
[X, Y] = sort(allpoints(4,:));
sortedpoints = allpoints(:,Y);

%sortedpoints(1,:) is start time, (2,:) is end time, (3,:) is duration

f = figure
n=1;
q=2;

lp = lowpass300(c);

while n <= size(sortedpoints,2);
	start = sortedpoints(1,n);
	finish = sortedpoints(2,n);
	duration = sortedpoints(3,n);
	div = finish-start;
	% plots LS event
	plot(d(1:div+1)-d(1), lp(start:finish)+q, 'b')
	% plot acc event
	plot(d(1:div+1)-d(1)+duration(n), acc(start:finish)+q, 'r')
	hold on
	q = q+2;
	n = n+1;
end

ylim([-10 ((size(sortedpoints,2).*2)+10)]);
xlim([-.1 max(duration)*2+.1])



