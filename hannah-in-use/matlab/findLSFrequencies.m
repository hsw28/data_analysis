function avg_transform = findLSFrequencies(LS_lfp_data, timestamp)

% takes raw LS LFP and finds the weird LS events and the time and duration
% plots the lowpass filtered (<300) LFP in order of duration
% also computes and plots the average frequency response magnitude of
% said events. Returns a matrix with frequencies in the first column and
% average magnitude response in the second
% ex
% findFrequencies(LS.data, LS.timestamp);

c = LS_lfp_data;
d = timestamp;



fil = lowpass300(c);
% filters data with bandpass filter between 100-300hz
% might want to change this to a low pass filter

% does a hilbert transformation on the data
h = hilbert(fil);
filtdata = abs(h);

% finds four std devs above mean
mn = mean(filtdata);
st = std(filtdata);
m = mn + (st.*(3));

%makes empty vector to hold times of ripples
rt=[];
peaktime=[];
LSevent=[];
Otherevent=[];
timeevent=[];
endpoints=[];
startpoints=[];
duration=[];
durr=[];

numevents = 0;

k=1;
% permute through transformed data and find when data is three std devs above mean
while k<=(size(filtdata,1))
	if filtdata(k) > m
		% we've found something above threshold, now need to find surrounding times when it's back at mean		
		
		% looks to see when value returns to half a std dev above mean, this is the start of the ripple time
		i = k;
		while abs(filtdata(i)-mn) >= (st./1.5) && i > 0 %STD DEV
			i=i-1;
		end
		
	

		% looks to see when value returns to 1/2 a std dev > mean & mantains this for 10 points, this is the end of event time		
		j = k;
		while j<size(filtdata,1)
			if abs(filtdata(j)-mn) >= (st./1.5) %STD DEV
				j=j+1;
			
			elseif size(filtdata,1)-j-225>=0 && all(abs(filtdata(j:j+225)-mn)<(st./1.5)) %STD DEV
		
				break
			elseif size(filtdata,1)-j-225<0 && all(abs(filtdata(j:end)-mn)<(st./1.5)) %STD DEV
				
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
				durr(end+1)=d(n);
			end

	
		[peak,index] = max(pt);
		index = index+i-1;
		%making a vector with start and end indices, with a ~45ms buffer around (equal to 7 time points)
		startpoints(end+1)=(i);
		endpoints(end+1)=(j);
		duration(end+1)=(d(j)-d(i));
		end

		k = k+1;
		
	elseif filtdata(k) <= m
		k = k+1;
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
