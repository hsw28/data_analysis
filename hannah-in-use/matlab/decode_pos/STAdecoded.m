function f = STAdecoded(eventtimes, decodedpos, plottime)

% finds spike triggered average -- filter yourself if you want to filter LFP
% bin size in seconds
% f = STA(eventtimes, lfp, time, binsize)


% want LFP forward of spike also i think... will need to eliminate events that fall in last bin too


time = decodedpos(4,:);


figure;
hold on;

if size(eventtimes, 2) > size(eventtimes, 1)
	eventtimes = eventtimes';
end

%trims eventtimes to eliminate times that fall in first bin & last bin
trimmedevents = [];
starttime = time(1)+time(plottime*2000);
endtime = time(end)-time(plottime*2000);
A = find(eventtimes >= starttime & eventtimes <= endtime);
trimmedevents = eventtimes(A);


wantedY = [];
for i=1:length(trimmedevents)
	starttime = trimmedevents(i)-plottime;
	endtime = trimmedevents(i)+plottime;

	[CS CSI] = min(abs(starttime-time));
	[CE CEI] = min(abs(endtime-time));



	if i == 1
		[CS CSI] = min(abs(starttime-time));
		[CE CEI] = min(abs(endtime-time));
		neededlength = (CEI-CSI);
		decodedposX = decodedpos(1,CSI:CEI);
		decodedposY = decodedpos(2,CSI:CEI);
		wantedX = decodedposX;
		wantedY = decodedposY;
	else
		[CS CSI] = min(abs(starttime-time));
		CEI = CSI+neededlength;
		decodedposX = decodedpos(1,CSI:CEI);
		decodedposY = decodedpos(2,CSI:CEI);
		wantedX = wantedX + decodedposX;
		wantedY = wantedY + decodedposY;
	end

end

%finds average

binnedX = wantedX./i;
binnedY = wantedY./i;

figure
plot(binnedX);
hold on
plot(binnedY);

xticks(0:round(length(binnedX))/2:round(length(binnedX)))

%xticklabels(xticks./(length(binnedX))*2)


xticklabels({-1*plottime , 0, plottime'})

xlabel('Sec.')
ylabel('Pos')



f= [binnedX, binnedY]';
