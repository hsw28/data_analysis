function f = thetathreshold(LFPthetaPOWERbinned, LFPtimestamps, vel)

%function f = thetathresholdRMSversion(rmstheta)
  %actually you dont need this if you use thetaRMS.. then you can just find mean and sd yourself
%finds theta threshold to eliminate SWR. make sure to use thetarms.m to find theta power for REMs etc


%LFPthetafilt = bintheta(LFPthetafilt, 1, .5)


if length(vel)>1
vel = assignvel(LFPtimestamps, vel);
vel = (vel(1,:));

t=1;
i=1;
highvel = [];
while t<=length(vel)-2000
  if length(find(vel(t:t+2000)<12))<1800
    highvel(end+1) = i;
  end
  i = i+1;
  t = t+1000;
end

LFPthetaPOWERbinned = LFPthetaPOWERbinned(highvel);
LFPthetaPOWERbinned = rmoutliers(LFPthetaPOWERbinned, 'median');

mn = mean(LFPthetaPOWERbinned);
sd = std(LFPthetaPOWERbinned);
threshold = mn-(2*sd);
f = threshold;

else

mn = mean(LFPthetaPOWERbinned)
sd = std(LFPthetaPOWERbinned)
threshold = mn-(2*sd);
f = threshold
end
