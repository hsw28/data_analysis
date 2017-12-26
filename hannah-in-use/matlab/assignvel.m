function f = assignvel(time, vel);
%takes input of velocity vector and upsamples from 60hz to 2000hz

velvector = vel(1,:);
veltime = vel(2,:);
[c timestart] = min(abs(time-veltime(1)));
[c timeend] = min(abs(veltime(end)-time));
time = time(timestart:timeend);


i = ceil(length(time)/length(velvector))-1;

%upvel = resample(velvector, i, 1);
%upveltime = resample(veltime, i, 1);
%
%f = [upvel; upveltime];

distorted = veltime(end-30);
[m index] = min(abs(time-distorted));

size(veltime)
%TO DEBUG IF NON UNIQUE VALUES IN TIME (OR WHATEVER)
[~,idxu,idxc] = (unique(veltime));
[count, ~, idxcount] = histcounts(idxc,numel(idxu));
idxkeep = count(idxcount)>1;
yuck = veltime(:, idxkeep); %GIVES YOU NON UNIQUE VALUE
size(yuck);
if length(yuck)>0
  [c index] = min(abs(veltime-yuck(1,2)));
  veltime(index) = veltime(index)+.015;
end


upvel = interp1(veltime, velvector, time(1:index), 'pchip');


f = upvel;
