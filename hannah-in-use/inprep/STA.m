function f = STA(eventtimes, lfp, time, binsize) 

% finds spike triggered average
% bin size in seconds

%trims eventtimes to eliminate times that fall in first bin
A = find(eventtimes > eventtimes(1)+time);
trimmedevents = [];
trimmedevents = eventtimes(A);

i = 1;
bintimes = [];
binnedLFP = zeros(binsize*2000,1);

while i <= size(trimmedevents)
	% get index for binning in time
	
	bintimes = find((time>trimmedevents(i)-binsize) & time<=trimmedevents(1));

	% add LFP data to a row of binned LFP, each row is for a different spikee
	while n<size(bintimes)
		binnedLFP(n) = binnedLFP(n) + lfp(bintimes(n));
		n+1;
	end
i = i+1;
end

%finds average
binnedLFPaverage = binnedLFP./trimmedevents;

f = plot(binsize*2000, binnedLFPaverage);





