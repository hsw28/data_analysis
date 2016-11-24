function ap = assignpos(time, pos);

% assigns position to all timepoints
% input time vector and position
% ap = assignpos(time, pos)

xcord = [pos(:,2), pos(:,1)];
xcord = xcord';
ycord = [pos(:,3), pos(:,1)];
ycord = ycord';

xcord = assignvel(time, xcord);
ycord = assignvel(time, ycord);

p = [time; xcord; ycord];
ap = p';
