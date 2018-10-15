function f = assignvel(time, vel);
%takes input of velocity vector and upsamples from 60hz to 2000hz
%USED TO ONLY OUTPUT VELOCITY NOW OUTPUTS VELOCITY WITH TIME. YOU NEED THIS. EDIT OTHER CODE TO FIT



[C, ia, ic] = unique(vel(2,:));
vel = vel(:,ia);

velvector = vel(1,:);
veltime = vel(2,:);

[c timestart] = min(abs(time-veltime(1)));
if timestart > 1
  warning('your time starts before your velocity and your time will be cut!')
  time = time(timestart:end);
end

[c timeend] = min(abs(veltime(end)-time));
if timeend < length(time)
  warning('your time ends after your velocity and your time will be cut')
  time = time(1:timeend);

elseif timeend > length(time)
  warning('your velocity ends after your time and your velocity will be cut!!!')
  [c velend] = min(abs(veltime-time(timeend)));
  velvector = velvector(1:velend);
  veltime = veltime(1:velend);
end



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



upvel = interp1(veltime, velvector, time, 'pchip');



f = [upvel; time];
