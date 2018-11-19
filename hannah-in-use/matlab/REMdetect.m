function [startend ratio] = REMdetect(unfilteredLFP, time, velvector, headdirection)
%varargin should be velocity
%To identify REM episodes, LFP traces were digitally bandpass filtered in the delta (2–4 Hz) and theta (6–10 Hz) bands
%power in each band was computed as the time-averaged squared amplitude of the filtered trace
% REM episodes were identified as periods of elevated theta-delta power ratio (> 2.0)
%To examine correspondence between long duration patterns and to reduce the detection
%of false-positive correlations associated with short duration patterns, we limited our analysis to REM episodes
%longer than 60 s in duration.


theta = thetafilt412(unfilteredLFP);
delta = deltafilt04(unfilteredLFP);

theta = theta.^2;
delta = delta.^2;


ratio = theta(1:length(delta))./delta;


if length(velvector)>1

  assvel = assignvel(time, velvector);
  asstime = (assvel(2,:));
  assvel = assvel(1,:);
else

  assvel = zeros(length(time),1);
  asstime = time;
end

if length(headdirection)>1
  hd = hdvelocity(headdirection);
  hd = assignvel(time, hd);
  hd = hd(1,:);
else
  hd = zeros(length(time),1);
end




%sliding window of 1sec with .5sec overlap
i=1;
remstart = [];
remend = [];
remtime = [];
meanr = []; %to keep track of ratios, not using right now
meanv = [];
while i<length(asstime)-2000
  meanratio = mean(ratio(i:i+2000));
  meanvel = mean(assvel(i:i+2000));
  meanr(end+1) = meanratio;
  meanv(end+1) = meanvel;
  meanr(end+1) = asstime(i);
  numbelow = length(find(assvel(i:i+2000)<5));
  meanhd = mean(abs(hd(i:i+2000)));
  j = i;

  %if meanratio > 2 & meanvel <=5 %REM detected
  if meanratio > 2 &  numbelow==length(assvel(i:i+2000)) & meanhd<.04 %REM detected

  meanr(end+1) = mean(ratio(j:j+2000));
  meanv(end+1) = mean(assvel(j:j+2000));
    %while j<length(asstime)-2000 & j<length(ratio)-2000 & mean(ratio(j:j+2000))>2 & mean(assvel(j:j+2000))<=5
    while j<length(asstime)-2000 & j<length(ratio)-2000 & mean(ratio(j:j+2000))>2 & (length(find(assvel(j:j+2000)<5))==length(assvel(j:j+2000))) & mean(abs(hd(j:j+2000)))<.04

      meanr(end+1) = mean(ratio(j:j+2000));
      meanv(end+1) = mean(assvel(j:j+2000));
      j = j+1000;
    end
    if time(j+1000)-time(i)>60
      remstart(end+1) = time(i);
      remend(end+1) = time(j+1000);
      remtime = [remtime, time(i:j)];
  %  end
  end
  i = j;
  i = i+1000;
end

REMfinish = remend;
REMbegin = remstart;


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
  if REMfinish2(f)-REMbegin2(f)>20 & REMfinish2(f)-REMbegin2(f)<300
    REMbegin3(end+1) = REMbegin2(f);
    REMfinish3(end+1) = REMfinish2(f);
  end
end

numberOfRems = length(REMbegin3)
startend = [REMbegin3; REMfinish3];
ratio = [meanr; time];







%startend = [remstart;remend];
%alltimes = remtime;
%ratio = [meanr; meanv];
