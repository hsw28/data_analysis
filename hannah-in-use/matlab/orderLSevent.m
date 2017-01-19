function f = orderLSevent(LS_lfp_data, timestamp);

% takes raw LS LFP and finds the weird LS events and the time and duration
% plots the lowpass filtered (<300) LFP in order of duration
% ex
% LSlfpcompare(LS.data, LS.timestamp);

c = LS_lfp_data;
d = timestamp;


filtdata = lowpass300(c);
% filters data with bandpass filter between 100-300hz

% does a hilbert transformation on the data
h = hilbert(filtdata);
trans = abs(h);

% finds three std devs above mean
mn = mean(trans);
st = std(trans);
m = mn + (st.*(3));

%makes empty vector to hold times of ripples
rt=[];
peaktime=[];
tst = 0;
start = [];
stop = [];
duration = [];
lengths = [];
startindex = [];
endindex = [];

k=1;
% permute through transformed data and find when data is three std devs above mean
while k<=(size(trans,1))
	if trans(k) > m 
		% we've found something above threshold, now need to find surrounding times when it's back at mean		
		
		% looks to see when value returns to half a std dev above mean, this is the start of the ripple time
		i = k;
		while abs(trans(i)-mn) >= (st./1.5) && i > 0 %STD DEV
			i=i-1;
		end
		
	

		% looks to see when value returns to st/1.5 a std dev > mean & mantains this for 10 points, this is the end of event time		
		j = k;
		while j<size(trans,1)
			if abs(trans(j)-mn) >= (st./1.2) %STD DEV
				j=j+1;
			
			elseif size(trans,1)-j-225>=0 && all(abs(trans(j:j+225)-mn)<(st./1.2)) %STD DEV
		
				break
			elseif size(trans,1)-j-225<0 && all(abs(trans(j:end)-mn)<(st./1.2)) %STD DEV
				
				break
			else
				j = j+1;
				
			end
		
		
		end
		

		%adds to vector ripple start, trigger, and end times		
		%start time is d(i);
		%end time is d(j);
		k = j;	
		

		%only include events longer than 1.25s
		if d(j)-d(i) > 1.25
			%making a vector with all the data points of the ripple
			pt=[];
			

			for n = (i):(j)	
				%goes through data and adds data (NOT TIME) to vector
				pt(end+1) = c(n);
				duration(end+1)=d(n);
			
			end
			
			%makes sure youre avoiding a huge noise bump
			if max(pt)<mn+st.*10 %didnt end up using so made this value really high so everything would be included	
				[peak,index] = max(pt);
				index = index+i-1;
				%adds peak time to vector
				peaktime(end+1) = d(index);
				%adds start time to vector
				start(end+1) = d(i);
				%adds stop time to vector
				stop(end+1)=d(j);
				% start time and peak time should have the same index
				lengths(end+1) = (d(j)-d(i));
				startindex(end+1) = i;
				endindex(end+1) = j;
			end
		end

		k = k+1;
		
	elseif trans(k) <= m
		k = k+1;
	end
end

allpoints = [start;stop;lengths;startindex;endindex];
[X, Y] = sort(allpoints(3,:));
sortedpoints = allpoints(:,Y);

%sortedpoints(1,:) is start time, (2,:) is end time, (3,:) is duration


figure
n=1;
q=2;

lp = lowpass300(c);
size(sortedpoints);
f = sortedpoints;
while n <= size(sortedpoints,2);
	start = sortedpoints(1,n);
	finish = sortedpoints(2,n);
	lengths = sortedpoints(3,n);
	startindex = sortedpoints(4,n);
	endindex = sortedpoints(5,n);
	div = endindex-startindex;
	% plots LS event
	plot(d(1:div+1)-d(1), lp(startindex:endindex)+q, 'b')
	%getting error with above line bc not integers for start:finish. instead need to find index values for start and finish and use those
	hold on
	q = q+2;
	n = n+1;
end

ylim([-10 ((size(sortedpoints,2).*2)+10)]);
xlim([-.1 max(lengths)+.1])









