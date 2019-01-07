function f = detectCloseEvents(ripplestime, eventtime, dif)

%find events that are a certain time away from a ripple. input your time in seconds in dif
%good for finding triggers within a certain distance from ripples.
%OUTPUTS INDEX

goodindex = [];
for n=1:length(eventtime)
  [c index] = (min(abs(ripplestime-eventtime(n))));
  %goodindex(end+1) = c;
  if abs(c(1)) <= dif
    goodindex(end+1) = n;
  end
end

f = goodindex;
%f = eventtime(goodindex);
