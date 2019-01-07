function f = STAdecoded(triggertimesONLY, pos4decoding, clusters4decoding, posdim, tdecoded, windowsz)
	%decodes position around a trigger event using POSdecodetrigger.m and finds triggered average of position
	%SELECTS 100 TRIGGERS RIGHT NOW, CAN CHANGE




window = windowsz;
triggertimes = triggertimesONLY;

figure;
hold on;

if size(triggertimes, 2) > size(triggertimes, 1)
	triggertimes = triggertimes';
end

if size(triggertimes,2)>1
	warning('DID YOU ONLY ENTER TIME FOR YOUR TRIGGER TIMES??? ')
end

%TO ONLY SELECT A SUBSET
%if length(triggertimes)>200
%	triggernum = 200;
%	selected = randperm(length(triggertimes), triggernum);
%	triggertimes = triggertimes(selected);
%end


trimmedevents = triggertimes;



	poses = POSdecodetrigger(trimmedevents, pos4decoding, clusters4decoding, posdim, tdecoded, window);
		wantedX = sum(poses.x);
		wantedY = sum(poses.y);


%finds average

binnedX = wantedX./length(trimmedevents);
binnedY = wantedY./length(trimmedevents);

length(binnedX)
figure
plot(binnedX);
hold on
plot(binnedY);

xticks(0:round(length(binnedX))/2:round(length(binnedX)))

%xticklabels(xticks./(length(binnedX))*2)


xticklabels({-1*window , 0, window'})
vline(round(length(binnedX))/2)

xlabel('Sec.')
ylabel('Pos')



%f = [binnedX; binnedY]';
f.x = poses.x;
f.y = poses.y;
f.percents = poses.percents;
