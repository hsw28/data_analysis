function f = orderLSevent(LS_lfp_data, timestamp);

% takes raw LS LFP and finds the weird LS events and the time and duration
% plots the lowpass filtered (<300) LFP in order of duration
% ex
% LSlfpcompare(LS.data, LS.timestamp);

c = LS_lfp_data;
d = timestamp;



fil = thetafilt(c);
% filters data with bandpass filter between 100-300hz
% might want to change this to a low pass filter

% does a hilbert transformation on the data
h = hilbert(fil);
filtdata = abs(h);

% finds four std devs above mean
mn = mean(filtdata);
st = std(filtdata);
m = mn + (st.*(4));

%makes empty vector to hold times of ripples
rt=[];
peaktime=[];
LSevent=[];
Otherevent=[];
timeevent=[];
endpoints=[];
startpoints=[];
duration=[];

numevents = 0;

% permute through transformed data and find when data is four std devs above mean
for k = 1:(size(filtdata))
	if filtdata(k) > m
		% we've found something above threshold, now need to find surrounding times when it's back at mean		
		
		% looks to see when value returns to half a std dev above mean, this is the start of the event time
		i = k;
		while abs(filtdata(i)-mn) >= (st./2) && i > 0
			i=i-1;
		end
		
		% looks to see when value returns to half a std dev above mean, this is the end of the event time		
		j = k;
		while abs(filtdata(j)-mn) >= (st./2)
			j=j+1;
		end
		
		%adds to vector ripple start, trigger, and end times		
		%start time is d(i);
		%end time is d(j);
		k = j;		
		
		
		%only include events longer than 30ms
		if d(j)-d(i) > .03
			if ismember((i-7),endpoints)==0 && ismember((j+7),endpoints)==0
				numevents = numevents+1;
				%making a vector with start and end indices, with a ~45ms buffer around (equal to 7 time points)
				startpoints(end+1)=(i-7);
				endpoints(end+1)=(j+7);
				duration(end+1)=(d(j+7)-d(i-7));
			end
		end


	end
end

allpoints = [startpoints;endpoints;duration];
[X, Y] = sort(allpoints(3,:));
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
	hold on
	q = q+2;
	n = n+1;
end

ylim([-10 ((size(sortedpoints,2).*2)+10)]);
xlim([-.1 max(duration)+.1])









