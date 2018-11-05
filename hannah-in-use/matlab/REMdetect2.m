function [startend ratio] = REMdetect2(unfilteredLFP, time, velvector)
%varargin should be velocity
%To identify REM episodes, LFP traces were digitally bandpass filtered in the delta (2–4 Hz) and theta (6–10 Hz) bands
%power in each band was computed as the time-averaged squared amplitude of the filtered trace
% REM episodes were identified as periods of elevated theta-delta power ratio (> 2.0)
%To examine correspondence between long duration patterns and to reduce the detection
%of false-positive correlations associated with short duration patterns, we limited our analysis to REM episodes
%longer than 60 s in duration.

fprintf('IS YOUR TIME THE SAME UNITS AS YOUR LFP???!?!?!??!')

theta = thetafilt412(unfilteredLFP);
delta = deltafilt04(unfilteredLFP);

theta = theta.^2;
delta = delta.^2;

if length(velvector)>1
  mintime = velvector(2,1);
  maxtime = velvector(2,end);
  [c startindex] = min(abs(time-mintime));
  [c endindex] = (min(abs(time-maxtime)));
  time = time(startindex:endindex);
  theta = theta(startindex:end);
  delta = delta(startindex:end);
  assvel = assignvel(time, velvector);
  asstime = (assvel(2,:));
  assvel = assvel(1,:);
else

  assvel = zeros(length(time),1)';
  asstime = time;
end


i = 1;
k = 0;
total = 0;
every = [];
tm = [];
meanv = [];
while i<length(asstime)-2000 & i<length(theta)-2000
currenttheta = rms(theta(i:i+2000));
currentdelta = rms(delta(i:i+2000));
ratio = currenttheta./currentdelta;
meanvel = mean(assvel(i:i+2000));
meanv(end+1) = meanvel;
total = total+ratio;
every(end+1) = ratio;
tm(end+1) = asstime(i);
k = k+1; %number of seconds
i = i+2000;
end

meanrat = mean(every);

REMbeginindex = [];
REMfinishindex = [];
REMbegin = [];
REMfinish = [];
for i=1:length(every)-3
  j = i;
  if every(i) > 2 & meanv(i)<3 & length(find(assvel((i-1)*2000+1:i*2000)<2))==2000 %rem start
    REMstart = tm(i);
    while (every(j)>2) & length(find(assvel((j-1)*2000+1:j*2000)<2))>1800
      j= j+1;
    end
    REMend = tm(j-1);
    j = j-1;
    %if REMend-REMstart > 1 %& REMend-REMstart<300
      REMbegin(end+1) = REMstart;
      REMfinish(end+1) = REMend;
      REMbeginindex(end+1) = i;
      REMfinishindex(end+1) = j;

    %end
  end
  i = j;
  i = i+1;
end


REMbegin2 = [];
REMfinish2 = [];
f = 1;
while f <= length(REMbegin)-1
  s = f+1;
  if abs(REMfinish(f)-REMbegin(s)) < 6
    REMbegin2(end+1) = REMbegin(f);
    while abs(REMfinish(f)-REMbegin(s)) < 10 & f<length(REMfinish)-1 %& mean(every(REMfinishindex(f)):REMbeginindex(s))>meanrat & length(find(assvel(f:s))<5)==s-f+1
    f = f+1;
    s = f+1;
    end
    REMfinish2(end+1) = REMfinish(s-1);
    s =s+1;
  else
    REMbegin2(end+1) =  REMbegin(f);
    REMfinish2(end+1) = REMfinish(f);
  end
    f = s;
end

REMbegin3= [];
REMfinish3 = [];
for f=1:length(REMbegin2)
  if REMfinish2(f)-REMbegin2(f)>20
    REMbegin3(end+1) = REMbegin2(f);
    REMfinish3(end+1) = REMfinish2(f);
  end
end

numberOfRems = length(REMbegin3)
startend = [REMbegin3; REMfinish3];
ratio = [every; tm];
