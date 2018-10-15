function [startend alltimes ratio] = REMdetect(unfilteredLFP, time, velvector)
%varargin should be velocity
%To identify REM episodes, LFP traces were digitally bandpass filtered in the delta (2–4 Hz) and theta (6–10 Hz) bands
%power in each band was computed as the time-averaged squared amplitude of the filtered trace
% REM episodes were identified as periods of elevated theta-delta power ratio (> 2.0)
%To examine correspondence between long duration patterns and to reduce the detection
%of false-positive correlations associated with short duration patterns, we limited our analysis to REM episodes
%longer than 60 s in duration.


theta = hightheta(unfilteredLFP);
delta = deltafilt04(unfilteredLFP);

theta = theta.^2;
delta = delta.^2;

ratio = theta./delta;

%velvector = cell2mat(varargin);
%if length(varargin)>1

  assvel = assignvel(time, velvector);
  asstime = (assvel(2,:));
  assvel = assvel(1,:);
%else
%  fprintf('we DONT have a vel')
%  assvel = zeros(length(time),1);
%end


%sliding window of 1sec with .5sec overlap
i=1;
remstart = [];
remend = [];
remtime = [];
meanr = []; %to keep track of ratios, not using right now
while i<length(asstime)-2000
  meanratio = mean(ratio(i:i+2000));
  meanvel = mean(assvel(i:i+2000));
  j = i;
  if meanratio > 2 & meanvel <= 5 %REM detected
    while j<length(asstime)-2000 & mean(ratio(j:j+2000))>2 & mean(assvel(j:j+2000))<=5
      mean(ratio(j:j+2000));
      j = j+1000;
    end
    if time(j+1000)-time(i)>30
      remstart(end+1) = time(i);
      remend(end+1) = time(j+1000);
      remtime = [remtime, time(i:j)];
    end
  end
  i = j;
  i = i+1000;
end

startend = [remstart;remend];
alltimes = remtime;
