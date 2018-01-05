function f = glmTEST2(cluster, time, pos)



[c timestart] = min(abs(time-pos(1,1)));
[c timeend] = min(abs(pos(end,1)-time));
time = time(timestart:timeend);

vel = noiselessVelocity(pos);
vel = assignvel(time, vel);


time = time(1:length(vel));

acc = accelfromvel(vel, time);
acc = acc(1,:);
%what is the format of vel entered? all times? spike times only? vector or matrix?
%trains = spiketrain(cluster, time);

vel = vel(2:end-2);
time = time(2:end-2);
vel = vel';
acc = acc';


trains = spiketrain(cluster, time);
spikeindex = find(trains);
N = length(spikeindex);

size(vel)
size(trains)

%model 1: only vel
b1 = glmfit([acc], trains, 'poisson')
lambda1 = exp(b1(1)+b1(2)*acc);
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
