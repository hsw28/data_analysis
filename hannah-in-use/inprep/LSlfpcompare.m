function f = LSlfpcompare(LS_lfp_data, LS_lfp_timestamp, other_LFP_data, other_LFP_data);

% takes raw LS LFP and finds the weird LS events and the time and duration
% plots the LFP for the other thing youre looking for during the same time

c = LS_lfp_data
d = LS_lfp_timestamp


filtdata = thetafilt(c);
% filters data with bandpass filter between 100-300hz

% does a hilbert transformation on the data
h = hilbert(filtdata);
trans = abs(h);

% finds four std devs above mean
mn = mean(trans);
st = std(trans);
m = mn + (st.*(4));

%makes empty vector to hold times of ripples
rt=[];
peaktime=[];

% permute through transformed data and find when data is four std devs above mean
for k = 1:(size(trans))
	if trans(k) > m
		% we've found something above threshold, now need to find surrounding times when it's back at mean		
		
		% looks to see when value returns to half a std dev above mean, this is the start of the ripple time
		i = k;
		while abs(trans(i)-mn) >= (st./2) && i > 0
			i=i-1;
		end
		
		% looks to see when value returns to half a std dev above mean, this is the end of the ripple time		
		j = k;
		while abs(trans(j)-mn) >= (st./2)
			j=j+1;
		end
		
		%adds to vector ripple start, trigger, and end times		
		%start time is d(i);
		%end time is d(j);
		k = j;		
		

		%only include events longer than 30ms
		if d(j)-d(i) > .03
			%making a vector start and end times
			pt=[];
			pt(end+1) = (d(i), d(j));
		end


	end
end

%pt vector contains two rows, which have start and stop times
% now want to plot those times and some surrounding times

% this is the number of plots we will need
plotsize = size(pt);

figure
subplot(plotsize, 1, 1);

for n = 1:plotsize
	


%find 


