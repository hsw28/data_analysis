function f = assignposOLD(time, pos)

% assigns position to all timepoints based on nearest point(no upsampling)
% input time vector and position
% ap = assignpos(time, pos)

xcord = [pos(:,2), pos(:,1)];
xcord = xcord';
ycord = [pos(:,3), pos(:,1)];
ycord = ycord';

xcord = assignvelOLD(time, xcord);
ycord = assignvelOLD(time, ycord);

size(time)
f = [time(1:length(xcord)); xcord; ycord];
