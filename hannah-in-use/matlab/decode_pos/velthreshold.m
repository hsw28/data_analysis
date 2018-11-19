function f = velthreshold(LFPtimestamps, vel)
%bins velocity and returns bin numbers that contain predominantly high velocities


vel = assignvel(LFPtimestamps, vel);
vel = smoothdata(vel(1,:), 'gaussian', 500);


t=1;
i=1;
highvel = [];
while t<=length(vel)-2000
  if length(find(vel(t:t+2000)<12))<1900
    highvel(end+1) = i;
  end
  i = i+1;
  t = t+1000;
end


f = highvel;
