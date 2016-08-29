
function p = findrip(c,d,y);
% finds ripples from eeg data by bandpass filtering, transforming, and then looking for signals >y dev above mean. returns a vector with the time of each ripple peak
%
% findrip(datavector,timevector,dev-above-mean)
% input data and timestamp structures from gh_debuffer.
% ex:
% findrip(lfp.data, lfp.timestamp, 4);


filtdata = ripfilt(c);
% filters data with bandpass filter between 100-300hz

% does a hilbert transformation on the data
h = hilbert(filtdata);
trans = abs(h);

% finds three std devs above mean
mn = mean(trans);
st = std(trans);
m = mn + (st.*y);

%makes empty vector to hold times of ripples
rt=[];
peaktime=[];

% permute through transformed data and find when data is three std devs above mean
for k = 1:(size(trans))
	if trans(k) > m
		% we've found something above threshold, now need to find surrounding times when it's back at mean		
		
		% looks to see when value returns to half a std dev above mean, this is the start of the ripple time
		i = k;
		while abs(trans(i)-mn) > (st./2) && i > 0
			i=i-1;
		end
		
		% looks to see when value returns to half a std dev above mean, this is the end of the ripple time		
		j = k;
		while abs(trans(j)-mn) > (st./2)
			j=j+1;
		end
		
		%adds to vector ripple start, trigger, and end times		
		%start time is d(i);
		%end time is d(j);
		k = j;		
		
		%only include events longer than 30ms
		if d(j)-d(i) > .03
			%making a vector with all the data points of the ripple
			pt=[];
			for n = i:j	
				pt(end+1) = c(n);
			end
		[peak,index] = max(pt);
		index = index+i-1;
		end

		peaktime(end+1) = d(index);

	end
end


%vector should have all peak times after getting rid of duplicates
p=unique(peaktime);




