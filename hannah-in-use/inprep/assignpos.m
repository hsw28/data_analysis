function ap = assignpos(time, pos);
% trying to do with interpolation. working... is unclear
% assigns position to all timepoints
% input time vector and position
% ap = assignpos(time, pos)

xcord = [pos(:,2), pos(:,1)];
xcord = xcord';
ycord = [pos(:,3), pos(:,1)];
ycord = ycord';
tm = pos(:,1);

x = pos(:,2);
y = pos(:,3);

[xcon,ind] = consolidator(x);
ind = find(x(ind));
xcord = [xcon, tm(ind)];
xcord = xcord';

%[ycon,ind] = consolidator(y(ind));
%ind = find(y(ind));
%ycord = [ycon, tm(ind)];
%ycord = ycord';

ycord = [y(ind), tm(ind)];
ycord = ycord';

xcord = assignvel(time, xcord);
ycord = assignvel(time, ycord);

time = time(1:length(xcord));
p = [time; xcord; ycord];
ap = p';
