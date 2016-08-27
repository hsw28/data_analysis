
function p = findrip(c,d);
% finds ripples from eeg data by bandpass filtering, transforming, and then looking for signals >3 dev above mean (is 3 good? that catches 3x more points than 4x above mean)
% input data and timestamp structures from gh_debuffer
% ex:
% findrip(lfp.data, lfp.timestamp);

% filters data with bandpass filter between 100-300hz
filtdata = ripfilt(c);

% does a hilbert transformation on the data
h = hilbert(filtdata);
trans = abs(h);

% finds three std devs above mean
mn = mean(trans);
st = std(trans);
m = mn + (st.*3);

%makes empty vector to hold times of ripples
rt=[];
peaktime=[];

% permute through transformed data and find when data is three std devs above mean
for k = 1:(size(trans))
	if trans(k) > m
		% we've found something above threshold, now need to find surrounding times when it's back at mean		
		i = k;
		% looks to see when value returns to half a std dev above mean, this is the start of the ripple time		
		while abs(trans(i)-mn) > (st./2) && i > 0
			i=i-1;
		end
		j = k;
		% looks to see when value returns to half a std dev above mean, this is the end of the ripple time		
		while abs(trans(k)-mn) > (st./2)
			j=j+1;
		end
		
		%adds to vector ripple start, trigger, and end times		
		%rt(end+1) = d(i);
		%rt(end+1) = d(j);
		k = j;		
		
		making a vector with all the data points of the ripple
		pt=[];
		for n = i:j	
			pt(end+1) = c(n);
		end
		[peak,index] = max(pt);
		index = index+i-1;

		peaktime(end+1) = d(index);

	end
end

% now you have a vector rt with times where amplitude is three+ std dev above mean
% want to get rid of multiple times super close to eachother
% stick these new times in a new vector

p=peaktime;



% next: filter with fir and blackman filter. do a hilbert transform to envelope. find mean-- ripples are 3+ deviations above mean. code ripple start and stop times as starting and ending at standard dev. ripple time is peak of ripple

