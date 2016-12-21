function f = cohere(lfpone, lfptwo, time, lowband, highband)
%put in two signals. filter them before if ya want
% input low and high bands you wanna look at
% does in one second periods

sz = size(lfpone,1);


allcoh = [];

i = 2000;
seconds = 0;
while i<=sz
	[wcoh,wcs,f] = wcoherence(lfpone(i-1999:i,1), lfptwo(i-1999:i,1), 2000);
	%find INDEX of values of frequency in theta band
	indx = find(f>lowband & f<highband);
	%those index values are the ones we wanna keep for wcoh
	wcoh = wcoh(indx, :);
	allcoh = horzcat(allcoh,wcoh);
	size(allcoh);
	seconds = seconds+i;
	i = i+2000;
	
end

% average across theta freq
% might not want to do this. not clear yet
meancoh = mean(allcoh, 1);

freq = f(indx);
coh = allcoh;



%plotting color map
figure
%pcolor(t,freq,allcoh);

%plotting average coherence v time

f = [meancoh; (time(1:i-2000))];

plot(time(1:i-2000), meancoh);
