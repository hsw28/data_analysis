function f = assignvel(time, vel);
%takes input of velocity vector and upsamples from 60hz to 2000hz

velvector = vel(1,:);
veltime = vel(2,:);
i = ceil(length(time)/length(velvector))-1;

%upvel = resample(velvector, i, 1);
%upveltime = resample(veltime, i, 1);
%
%f = [upvel; upveltime];

distorted = veltime(end-30);
[m index] = min(abs(time-distorted));
upvel = interp1(veltime, velvector, time(1:index), 'pchip');


f = upvel;
