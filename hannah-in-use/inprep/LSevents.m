function LStimes = LSevents(c,d,y);
% finds peaks from eeg data by <300 filtering, transforming, and then looking for signals >y dev above mean. returns a vector with the time of each ripple peak
%
% findrip(datavector,timevector,dev-above-mean)
% input data and timestamp structures from gh_debuffer.
% ex:
% findrip(lfp.data, lfp.timestamp, 4);


filtdata = lowpass300(c);
% filters data with bandpass filter between 100-300hz

% does a hilbert transformation on the data
h = hilbert(filtdata);
trans = abs(h);

% finds three std devs above mean
mn = mean(trans);
st = std(trans);
m = mn + (st.*(y));

%makes empty vector to hold times of ripples
rt=[];
peaktime=[];
tst = 0;
start = [];
stop = [];
duration = [];

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
		
	

		% looks to see when value returns to 1/2 a std dev > mean & mantains this for 10 points, this is the end of event time		
		j = k;
		while j<size(trans,1)
			if abs(trans(j)-mn) >= (st./1) %STD DEV
				j=j+1;
			
			elseif size(trans,1)-j-230>=0 && all(abs(trans(j:j+230)-mn)<(st./1.5)) %STD DEV
		
				break
			elseif size(trans,1)-j-230<0 && all(abs(trans(j:end)-mn)<(st./1.5)) %STD DEV
				
				break
			else
				j = j+1;
				
			end
		
		
		end
		

		%adds to vector ripple start, trigger, and end times		
		%start time is d(i);
		%end time is d(j);
		k = j;	
		

		%only include events longer than .15s
		if d(j)-d(i) > .2
			%making a vector with all the data points of the ripple
			pt=[];
			

			for n = (i):(j)	
				%goes through data and adds data (NOT TIME) to vector
				pt(end+1) = c(n);
				duration(end+1)=d(n);
			end

	
		[peak,index] = max(pt);
		index = index+i-1;
		%adds start time to vector
		start(end+1) = d(i);
		%adds peak time to vector
		peaktime(end+1) = d(index);
		% start time and peak time should have the same index
		end

		k = k+1;
		
	elseif trans(k) <= m
		k = k+1;
	end
end



%uncomment to return peak times
%p=peaktime;
%LStimes=p'

%uncomment to return start times
%p = start;
%LStimes=p';

%uncomment to return duration times
p = duration;
LStimes=p;

