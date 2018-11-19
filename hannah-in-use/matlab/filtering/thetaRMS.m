function f = thetaRMS(LFPthetafilt, time)
%finds theta power using thetaRMS for 1 second windows with .5 overlap

%thetapower = LFPthetafilt.^2;

i=1;
rmstheta = [];
newtime = [];
while i<length(LFPthetafilt)-2000
  rmstheta(end+1) = rms(LFPthetafilt(i:i+2000));
  newtime(end+1) = time(i);
  i = i+1000;

end

f.timestamp = newtime;
f.data = rmstheta;
