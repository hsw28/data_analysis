function [startend alltimes ratio] = REMdetect2(unfilteredLFP, time, velvector, headdirection)
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


%ratio = theta(1:length(delta))./delta;



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




%Filter, square, bin, rms, ratio
i=1;
remstart = [];
remend = [];
remtime = [];
meanr = []; %to keep track of ratios, not using right now
meanv = [];
t = [];
while i<length(asstime)-2000
  currenttheta = rms(theta(i:i+2000));
  currentdelta = rms(delta(i:i+2000));
  meanratio = currenttheta./currentdelta;
  meanvel = mean(assvel(i:i+2000));
  meanr(end+1) = meanratio;
  meanv(end+1) = meanvel;
  t(end+1) = asstime(i);
  numbelow = length(find(assvel(i:i+2000)<5));
  meanhd = mean(abs(hd(i:i+2000)));
  j = i;

  %if meanratio > 2 & meanvel <=5 %REM detected
  if meanratio > 2 &  numbelow==length(assvel(i:i+2000)) & meanhd<.04 %REM detected

  meanr(end+1) = (rms(theta(j:j+2000))./rms(delta(j:j+2000)));
  meanv(end+1) = mean(assvel(j:j+2000));
  t(end+1) = asstime(j);
    %while j<length(asstime)-2000 & j<length(ratio)-2000 & mean(ratio(j:j+2000))>2 & mean(assvel(j:j+2000))<=5
    while j<length(asstime)-2000 & (rms(theta(j:j+2000))./rms(delta(j:j+2000)))>2 & (length(find(assvel(j:j+2000)<5))==length(assvel(j:j+2000))) & mean(abs(hd(j:j+2000)))<.04

      meanr(end+1) = (rms(theta(j:j+2000))./rms(delta(j:j+2000)));
      meanv(end+1) = mean(assvel(j:j+2000));
      t(end+1) = asstime(j);
      j = j+2000;
    end
    if time(j+1000)-time(i)>5
      remstart(end+1) = time(i);
      remend(end+1) = time(j+1000);
      remtime = [remtime, time(i:j)];
    end
  end
  i = j;
  i = i+2000;
end

startend = [remstart;remend];
alltimes = remtime;
ratio = [meanr; meanv; t];
