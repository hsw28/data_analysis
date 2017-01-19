function fs = cohere(lfpone, lfptwo, time, lowband, highband)
%put in two signals. filter them before if ya want
% input low and high bands you wanna look at
% does in one half second abutting periods-- may want to later change that to overlapping periods

sz = size(lfpone,1);


allcoh = [];

i = 1000;
seconds = 0;
while i<=sz
	[wcoh,wcs,f] = wcoherence(lfpone(i-999:i,1), lfptwo(i-999:i,1), 1000);
	%find INDEX of values of frequency in theta band
	indx = find(f>lowband & f<highband);
	%those index values are the ones we wanna keep for wcoh
	wcoh = wcoh(indx, :);
	allcoh = horzcat(allcoh,wcoh);
	size(allcoh);
	seconds = seconds+i;
	i = i+1000;

end
% average across theta freq
% might not want to do this. not clear yet
meancoh = mean(allcoh, 1);

freq = f(indx);
coh = allcoh;



%plotting color map
%pcolor(t,freq,allcoh);

%plotting average coherence v time

%fs = [meancoh; 1:size(meancoh)-1];
fs = [meancoh; (time(1:i-1000))];

%plot(1:size(meancoh)-1, meancoh)
plot(time(1:i-1000), meancoh, 'LineWidth', 3);

x= time(1:i-1000);
coeffs = polyfit(x, meancoh, 1);
% Get fitted values
fittedX = linspace(min(x), max(x), 200);
fittedY = polyval(coeffs, fittedX);
% Plot the fitted line
hold on;
plot(fittedX, fittedY, 'r-', 'LineWidth', 2);
