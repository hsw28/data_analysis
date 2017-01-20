function f = STA(eventtimes, lfp, time, binsize)

% finds spike triggered average -- filter yourself if you want to filter LFP
% bin size in seconds
% f = STA(eventtimes, lfp, time, binsize)


% want LFP forward of spike also i think... will need to eliminate events that fall in last bin too

figure;
hold on;
%lfp = lfp.*lfp;

if size(eventtimes, 2) > size(eventtimes, 1)
	eventtimes = eventtimes';
end

%trims eventtimes to eliminate times that fall in first bin & last bin
trimmedevents = [];
starttime = time(1)+binsize;
endtime = time(end)-binsize;
A = find(eventtimes >= starttime & eventtimes <= endtime);
trimmedevents = eventtimes(A);



i = 1;
bintimes = [];
binnedLFP = zeros(binsize*2000*2,1);
q=1;
currentLFP = zeros(binsize*2000*2,1);

%FOR TESTING
%{
p = 1;
testvec = [];
while p<size(trimmedevents,1)
	q = 1;
	testvec(end+1) = trimmedevents(p);
	while abs(trimmedevents(p)-trimmedevents(p+q))<.5 & p+q<size(trimmedevents,1)
		q = q+1; %for testing
	end
	p=p+q;
end
trimmedevents=testvec';
size(trimmedevents)
%END TESTING
%}

while i <= size(trimmedevents,1)

	% get index for binning in time
	% time of event
	q = trimmedevents(i);

	%find index for start of event

	(q+binsize);
	if find((abs(time-(q+binsize))<.0001))
		%timeendevent = find((abs(time-(q+binsize))<.0001))
		timeendevent = find((abs(time-(q))<.0001));
		timeendevent = timeendevent + binsize*2000;
	else
		timeendevent = find((abs(time-(q))<.0025));
		timeendevent = timeendevent(1);
		timeendevent = timeendevent + binsize*2000;

	end


	timestartevent = timeendevent-((binsize*2000)*2);
	% add LFP data to a row of binned LFP, each row is for a different spikee


	n=(timestartevent);
	timeendevent;

	z = 1;

	size(binnedLFP);
	size(lfp);
	while z<= (binsize*2000*2)
		binnedLFP(z);
		(n-1+z);
		lfp((n-1+z));
		binnedLFP(z);
		binnedLFP(z) = binnedLFP(z) + lfp(n-1+z);
		currentLFP(z) = lfp((n-1+z));
		z = z+1;
	end
	LFPmean = mean(currentLFP);
	binnedLFP = binnedLFP-LFPmean;
	currentLFP = currentLFP-LFPmean;
	size(currentLFP);
	size(binnedLFP);


%	plot(((-size(binnedLFP)/2):size(binnedLFP)/2-1)/2000, currentLFP', 'Color', 	[0.5 0.5 0.5]);
	currentLFP = [];

i = i+1;
end

%finds average

binnedLFPaverage = (binnedLFP./size(trimmedevents,1));
%binnedLFPaverage = (binnedLFP);
f= binnedLFPaverage;

hold on

%plot((((-size(binnedLFPaverage)))/(binsize)+1:0), binnedLFP', 'k');
plot(((-size(binnedLFPaverage)/2):size(binnedLFPaverage)/2-1)/2000, binnedLFPaverage', 'k');
xlabel('Sec.')
ylabel('LFP')



f= binnedLFPaverage';
