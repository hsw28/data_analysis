function f = assignposOLD(time, pos)

% assigns position to all timepoints based on nearest point(no upsampling)
% input time vector and position
% ap = assignpos(time, pos)
size(pos)
postime = pos(:,1);
size(postime)
[c timestart] = min(abs(time-postime(1)));
[c timeend] = min(abs(postime(end)-time));


if timeend < length(time)
  warning('your time ends after your velocity and your time will be cut')
  time = time(1:timeend);
  1;
elseif timeend > length(time)
  warning('your time ends after your velocity and your velocity will be cut!!!')
  [c velend] = min(abs(postime-time(timeend)));
  velvector = velvector(1:velend);
  postime = postime(1:velend);
  2;
end
if timestart > time(1)
  warning('your time starts before your velocity and your time will be cut')
  time = time(timestart:end);
  3;
end


xcord = [pos(:,2), pos(:,1)];
xcord = xcord';
ycord = [pos(:,3), pos(:,1)];
ycord = ycord';

size(xcord);
size(ycord);

xcord = assignvelOLD(time, xcord);
ycord = assignvelOLD(time, ycord);

size(time)
size(xcord)
size(ycord)
f = [time(1:length(xcord)); xcord; ycord];
