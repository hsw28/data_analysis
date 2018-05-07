function f = glmTEST4(cluster, time, pos, dir)


[c timestart] = min(abs(time-pos(1,1)));
[c timeend] = min(abs(pos(end,1)-time));
time = time(timestart:timeend);

vel = noiselessVelocity(pos);
vel = assignvel(time, vel);
time = vel(2,:);
vel = vel(1,:);




time = time(1:length(vel));

acc = accelfromvel(vel, time);
acc = acc(1,:);

posX = [pos(:,2), pos(:,1)]; %[xpos, time]
posX = assignvel(time,posX');
posX = posX(1,:);

posY = [pos(:,2), pos(:,1)]; %[xpos, time]
posY = assignvel(time,posY');
posY = posY(1,:);


vel = vel(2:end-2);
time = time(2:end-2);
posX = posX(2:end-2);
posY = posY(2:end-2);
size(vel)


vel = vel';
acc = acc';
posX = posX';
posY = posY';

%{
[towardreward, awayfromreward] = centerdirection(pos);
k =1;
dir = zeros(2, length(pos));
while k <= length(pos)
  [cto indexto] = min(abs(pos(k,1)-towardreward));
  [caway indexaway] = min(abs(pos(k,1)-awayfromreward));

  if abs(pos(k,1)-towardreward(indexto)) < .1
      times = pos(k,1);
      dir(:,k) = [times; 1]; % assign timestamp 1 if going to toreward
  elseif abs(pos(k,1)-awayfromreward(indexaway)) < .1
      times = pos(k,1);
      dir(:,k) = [times; -1]; % assign -1 if going to away from reward
  else
      times = pos(k,1);
      dir(:,k) = [times; 0]; % assign 0 if not in center
  end
k = k+1;
end
dir = assignvelOLD(time, dir);
dir = dir';
%}


trains = spiketrain(cluster, time);

%notstillindex = find(vel>20 & (acc<-9 | acc>9));
%notstillindex = find(vel>20);
%vel = vel(notstillindex);
%acc = acc(notstillindex);
%posX = posX(notstillindex);
%posY = posY(notstillindex);
%trains = trains(notstillindex);




spikeindex = find(trains==1);
N = length(spikeindex);



%model 1: only vel
[b1,dev,stats] = glmfit([vel acc posX], trains, 'poisson');
b1
lambda1 = exp(b1(1)+b1(2)*vel+b1(3)*acc+b1(4)*posX);
%lambda1 = exp(b1(2)*vel.^3);


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

Ivel_p = stats.p(2)
Iacc_p = stats.p(3)
dir_p = stats.p(4)

% confidence bounds
  CI = [b1-2*stats.se b1+2*stats.se]
  CI_lower2 = exp(b1(2)-2*stats.se(2));
  CI_upper2 = exp(b1(2)+2*stats.se(2));

  CI_lower2 = exp(b1(3)-2*stats.se(3));
  CI_upper2 = exp(b1(3)+2*stats.se(3));

  CI_lower2 = exp(b1(4)-2*stats.se(4));
  CI_upper2 = exp(b1(4)+2*stats.se(4));
% and pval


R = cumsum(stats.resid);
figure
plot(R);
title('resid cumsum')

f = dir;
