function f = assignposOLD(time, pos)

% assigns position to all timepoints based on nearest point(no upsampling)
% input time vector and position
% ap = assignpos(time, pos)

postime = pos(:,1);
time = sort(time);
[c timestart] = min(abs(time-postime(1)));
[c timeend] = min(abs(postime(end)-time));

timestart;
timeend;
time = time(timestart:timeend);


[c timestart] = min(abs(postime-time(1)));
[c timeend] = min(abs(postime-postime(end)));

xcord = [pos(timestart:timeend,2), pos(timestart:timeend,1)];
xcord = xcord';
ycord = [pos(timestart:timeend,3), pos(timestart:timeend,1)];
ycord = ycord';

postime = (timestart:timeend);



%{
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
%}



size(xcord);
size(ycord);

xcord = assignvelOLD(time, xcord);
ycord = assignvelOLD(time, ycord);


f = [time(1:length(xcord)); xcord; ycord]';
