function f = glmTEST2(cluster, time, pos)



[c timestart] = min(abs(time-pos(1,1)));
[c timeend] = min(abs(pos(end,1)-time));
time = time(timestart:timeend);

vel = noiselessVelocity(pos);
vel = assignvel(time, vel);


time = time(1:length(vel));

acc = accelfromvel(vel, time);
acc = acc(1,:);


%UN COMMENT IF YOU WANT DIRECTION
%{
[towardreward, awayfromreward] = centerdirection(pos);
k =1;
dir = zeros(2, k);
while k <= length(pos)
  [cto indexto] = min(abs(pos(k,1)-towardreward));
  [caway indexaway] = min(abs(pos(k,1)-awayfromreward));
  if abs(pos(k,1)-cto) < .001
      dir(:,k) = [pos(k,1), 1]; % assign timestamp 1 if going to toreward
  elseif abs(pos(k,1)-caway) < .001
      dir(:,k) = [pos(k,1), 1]; % assign -1 if going to away from reward
  else
      dir(:,k) = [pos(k,1), 0]; % assign 0 if not in center
  end
k = k+1;
end
dir = assignvelOLD(time, dir);
dir = dir(2:end-2);
dir = dir';
%}

posX = [pos(:,2), pos(:,1)]; %[xpos, time]
posX = assignvel(time,posX');

posY = [pos(:,2), pos(:,1)]; %[xpos, time]
posY = assignvel(time,posY');

vel = vel(2:end-2);
time = time(2:end-2);
posX = posX(2:end-2);
posY = posY(2:end-2);
size(vel)


vel = vel';
acc = acc';
posX = posX';
posY = posY';




trains = spiketrain(cluster, time);
spikeindex = find(trains);
N = length(spikeindex);



%model 1: only vel
b1 = glmfit([vel acc posX], trains, 'poisson')
lambda1 = exp(b1(1)+b1(2)*vel+b1(3)*acc+b1(4)*posX);
%lambda1 = exp(b1(2)*vel.^3);
figure
plot(lambda1)
A(1) = sum(lambda1(1:spikeindex(1)));
for i = 2:N
    A(i) = sum(lambda1(spikeindex(i-1):spikeindex(i)));
end
[eCDF, zvals] = ecdf(A);
mCDF = 1-exp(-zvals);
figure
plot(mCDF, eCDF)
hold on
plot([0 1], [0 1]+1.36/sqrt(N), 'k') %why is this the confidence bound?
plot([0 1], [0 1]-1.36/sqrt(N), 'k')
hold off
xlabel('Model CDF')
ylabel('Emperical CDF')
title('model 1: only vel')
