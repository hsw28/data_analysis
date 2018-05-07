function f = middlevel(midtimes, assvel)

%use middletimes.m to get middle times, then into this function put either times to or times away
% can use ass vel or ass acc, whatever

k = 1;
velvector = [];
avvector = [];
while k<length(midtimes)
  [c startindex] = min(abs(assvel(2,:)-midtimes(k)));
  [c endindex] = min(abs(assvel(2,:)-midtimes(k+1)));
  velvector = horzcat(velvector, assvel(:, startindex:endindex));
  assvel(2, endindex)-assvel(2,startindex);
  av = sum(assvel(1, startindex:endindex))/(endindex-startindex);
  avvector(end+1) = av;
  k = k+2;
end

velvector;
f = avvector;
