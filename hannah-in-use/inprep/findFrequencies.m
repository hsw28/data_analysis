function avg_transform = findFrequencies(LS_lfp_data, timestamp)

% takes raw LS LFP and finds the weird LS events and the time and duration
% plots the lowpass filtered (<300) LFP in order of duration
% also computes and plots the average frequency response magnitude of
% said events. Returns a matrix with frequencies in the first column and
% average magnitude response in the second
% ex
% findFrequencies(LS.data, LS.timestamp);

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


f = {};
n=1;
q=2;

lp = lowpass300(c);
figure
while n <= size(sortedpoints,2);
	start = sortedpoints(1,n);
	finish = sortedpoints(2,n);
	duration = sortedpoints(3,n);
	div = finish-start;
	% plots LS event
	plot(d(1:div+1)-d(1), lp(start:finish)+q, 'b')
    f{n+1,1} = d(1:div+1)-d(1);
    f{n+1,2} = lp(start:finish)+q;
	hold on
	q = q+2;
	n = n+1;
end

ylim([-10 ((size(sortedpoints,2).*2)+10)]);
xlim([-.1 max(duration)+.1])

Fs = 2000; %data sampling rate
s = size(f); %length of object that holds LS events
figure
transforms = zeros(2549,1); %empty vector to hold FFT sequences
for i = 2:s(1)
    data = f{i,2}; %current event to transform
    avg = mean(data); 
    data = data - avg; %remove DC offset
    L = 5096;
    Y = fft(data,L); %take 5096 point DFT
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    transforms = transforms + P1; %accumulate transform
end
freq = Fs*(0:(L/2))/L; %generate frequency axis
transforms = transforms/(s(1)-1); %average transforms
avg_transform = [freq',transforms];
plot(freq,transforms); %plot average frequency response of LS events