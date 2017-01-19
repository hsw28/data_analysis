function [middle, notmiddle] = LSeventsmiddle(LSevent, pos)
  %outputs 2 vectors: one of LSevents in the middle and one of LSevents not in the middle
  %LS events must be a list of start and stop times of LS events

  tme = pos(:,1);
  tme = tme';
  xpos = pos(:,2);
  xpos = xpos';
  ypos = pos(:,3);
  ypos = ypos';

  xmid = find(xpos>450 & xpos<850); %FOR MIDDLE ARM FULL
  ymiddle = find(ypos>350 & ypos<370);
  %find indices that appear in both
  bothindex = intersect(xmid, ymiddle);
  %assign these to points
  timemiddle = tme(bothindex);
  timemiddle = timemiddle';

i = 1;
notmiddle = [];
middle = [];
while i <= size(LSevent,2)
  starting = LSevent(1,i); %start
  ending = LSevent(1,i+1); %end
  x = find(timemiddle>starting & timemiddle<ending);
  timemiddle(x);
  if size(x,1) == 0 %middle times dont overlap with event times
      notmiddle(end+1) = starting;
      notmiddle(end+1) = ending;
  elseif size(x,1) > 0 %middle times DO overlap with event times
      middle(end+1) = starting;
      middle(end+1) = ending;
  end
i = i+2;
end
