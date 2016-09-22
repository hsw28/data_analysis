function f = acc_lfp(lfpdata, lfptimestamp, pos);

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
	if acc(k) > 200 | acc(k) <(-200)
		% we've found high acceleration or decelleration
		% looks to see when value returns to a low value, this is the start of the acc time
		i = k;
		while acc(i) > 200 | acc(i) < -200  && i>0
			i=i-1;
		end
		
		% looks to see when value returns this is the end of the acc time		
		j = k;
		while acc(j) > 200 | acc(j) < -200 && j<=(size(acc,2)-1)
			j=j+1;
		end

		%start time is d(i);
		%end time is d(j);
		k = j;		

		if size(d,2)-j <=10
			j = size(d,2);
		end

		%only include events longer than 500ms
		if d(j)-d(i) > .5
			if ismember((i),startpoints)==0 && ismember((j),endpoints)==0
				numevents = numevents+1;
				%making a vector with start and end indices
				%if (size(d,2)-j)>=10 && i>10
				condition = 1;	
				startpoints(end+1)=(i);
				endpoints(end+1)=(j);
				duration(end+1)=(d(j)-d(i));
				accmag(end+1) = mean(acc(i:j));
			end
		end
	end
end

%sort points by magnitude of acceleration
allpoints = [startpoints;endpoints;duration;accmag];
[X, Y] = sort(allpoints(4,:));
sortedpoints = allpoints(:,Y);

%sortedpoints(1,:) is start time, (2,:) is end time, (3,:) is duration

f = figure;
n=1;
q=2;
numevents;

lp = lowpass300(c);
d = d';
while n <= size(sortedpoints,2);
	start = sortedpoints(1,n);
	finish = sortedpoints(2,n);
	duration = sortedpoints(3,n);
	mag = sortedpoints(4,n);
	div = finish-start;

	% plots whole LS event
	%plot(d(1:(div+1))-d(1), lp(start:finish)+q, 'k')
	plot(d(start:finish)-d(start), lp(start:finish)+q, 'k')
	hold on
	%mark max accell
	
	%max accell
	[mx,ind]=max(abs(acc(start:finish)));
	%plot(d(ind)-d(start), lp(ind)+q,'-.xr')
	plot(d(ind+start)-d(start), lp(ind+start)+q,'-.xr')


	% plot during duration of acc (was so small this was stupid)
	%plot(d(11:div-9)-d(1), lp(start+10:finish-10)+q, 'r')
	
	% plot acc event
	%add next line back in if you wanna plant accell
	%plot(d(1:div+1)-d(1)+duration+.25, (acc(start:finish)/1000)+q-(acc(start)/1000), 'r')
	%plot(d(1:div+1)-d(1), (acc(start:finish)/1000)+q-(acc(start)/1000), 'r')
	q = q+2;
	n = n+1;
end

ylim([-10 ((size(sortedpoints,2).*2)+10)]);
xlim( [-1 inf]);
%xlim( [-1 (max(duration*2)+5)]);


