
function p = findrip(unfilteredLFP, timevector, devAboveMean, pos);
% finds ripples from eeg data by bandpass filtering, transforming, and then looking for signals >y dev above mean. returns a vector [ripple start; ripplepeak]
% uses position to only get ripples from when animal is not moving
% ex:
% findrip(lfp, lfp, 4, pos);

c = unfilteredLFP;
d = timevector;
y = devAboveMean;

filtdata = ripfilt(c);
% filters data with bandpass filter between 100-300hz

% does a hilbert transformation on the data
h = hilbert(filtdata);
trans = abs(h);

%guassian smoothing of 4ms (8 samples)
w = gausswin(8);
trans = filter(w, 1, trans);

delay = length(d)-length(trans);
d = d(1:end-delay);

% gets rid of extreme values and finds std devs above mean
trans2 = trans;
bigpoints = find(trans2>.5);
trans2(bigpoints) = .5;
mn = mean(trans2);
st = std(trans2);
m = mn + (st.*y);

%also finds 6 std dev above mean to rule out huge things
%big = mn + (st.*6);

%makes empty vector to hold times of ripples
rt=[];
peaktime=[];
starts = [];

% gets velocity
vel = noiselessVelocity(pos);
vel = assignvel(d, vel);

% permute through transformed data and find when data is three std devs above mean
for k = 1:(size(trans))
	if trans(k) > m && vel(k) < 3

		% we've found something above threshold, now need to find surrounding times when it's back at mean

		% looks to see when value returns to half a std dev above mean, this is the start of the ripple time
		i = k;
		while i>0 && abs(trans(i)-mn) > (st./2)
			i=i-1;
		end

		% looks to see when value returns to half a std dev above mean, this is the end of the ripple time
		j = k;
		while abs(trans(j)-mn) > (st./2) && j<length(trans)
			j=j+1;
		end


		%adds to vector ripple start, trigger, and end times
		%start time is d(i);
		%end time is d(j);
		k = j;

		%only include events longer than 30ms

		if i>0 && d(j)-d(i) > .02
			%making a vector with all the data points of the ripple
			pt=[];

			for n = i:j

				%goes through data and adds data (NOT TIME) to vector
				pt(end+1) = c(n);

			end

			% makes sure ripple isn't from a huge fluxtuation like the wire getting disconnected
			%peakpoint = max(pt);
			%if peakpoint < big
				[peak,index] = max(pt);
				index = index+i-1;
				peaktime(end+1) = d(index);
				starts(end+1) = d(i);

			%end
		end

	end
end


%vector should have all peak times after getting rid of duplicates
peaks=unique(peaktime);
starts = unique(starts);


p = [starts; peaks];
