
function rip = findrip(c,d);
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

% permute through transformed data and find when data is three std devs above mean
for k = 1:(size(trans))
	if trans(k) > m
		% we've found something above threshold, now need to find surrounding times when it's back at mean		
		i = k;
		% looks to see when value returns to half a std dev above mean, this is the start of the ripple time		
		%while abs(trans(i)-mn) > (st./2)
			%i=i-1;
		%end
		% looks to see when value returns to half a std dev above mean, this is the end of the ripple time		
		while abs(trans(k)-mn) > (st./2)
			k=k+1;
		end
		
		%adds to vector ripple start and stop times, in pairs
		rt(end+1) = d(i);
		rt(end+1) = d(k);	
	end
end

% now you have a vector rt with times where amplitude is three+ std dev above mean
% want to get rid of multiple times super close to eachother
% stick these new times in a new vector

rt2=[];


% add point to new vector only if it is 50ms after previous time point. this makes sure that only the first instance past the threshold gets recorded
% this isn't working now bc all points are too close
for k = 1:(size(rt))
	if k==1
		rt2(end+1) = rt(k)	
	elseif (rt(k)-rt(k-1)) > .050	
		% rt2(end+1) = rt(k)
	end
end

rip=rt;



% next: filter with fir and blackman filter. do a hilbert transform to envelope. find mean-- ripples are 3+ deviations above mean. code ripple start and stop times as starting and ending at standard dev. ripple time is peak of ripple

