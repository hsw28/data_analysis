function f = upsample(vel);
%takes input of velocity vector and upsamples from 60hz to 2000hz

velvector = vel(1,:);
f = resample(velvector, 38402, 567);
