function ap = assignpos(time, pos);
% trying to do with interpolation. working... is unclear
% assigns position to all timepoints
% input time vector and position
% ap = assignpos(time, pos)

postime = pos(:,1);
[c timestart] = min(abs(time-postime(1)));
[c timeend] = min(abs(postime(end)-time));


if timeend < length(time)
  warning('your time ends after your velocity and your time will be cut')
  time = time(1:timeend);

elseif timeend > length(time)
  warning('your time ends after your velocity and your velocity will be cut!!!')
  [c velend] = min(abs(postime-time(timeend)));
  velvector = velvector(1:velend);
  postime = postime(1:velend);
end

if timestart > time(1)
  warning('your time starts before your velocity and your time will be cut')
  time = time(timestart:end);
end

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
p = [time; xcord(1,:); ycord(1,:)];
ap = p';
