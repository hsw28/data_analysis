function f = assignTickTime(ticktimes, eventticks);

% using a file from extracttick.py for tick times, and video ticks of an event, output times of the event

i = 1;
eventtimes = [];
while i <= length(eventticks)
  time = find(ticktimes(:,2)==eventticks(i));
  eventtimes(end+1) = ticktimes(time, 1);
  i = i+1;
end

f = eventtimes;
