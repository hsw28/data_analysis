function f = glmTEST(cluster, time, pos)

  clustsize = length(cluster);

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
%what is the format of vel entered? all times? spike times only? vector or matrix?
%trains = spiketrain(cluster, time);

vel = vel(2:end-2);
time = time(2:end-2);
vel = vel';
acc = acc';

trains = spiketrain(cluster, time);
spikeindex = find(trains);
N = length(spikeindex)

%model 1: only vel
b1 = glmfit(vel, trains, 'poisson')
lambda1 = exp(b1(1)+b1(2)*vel);
figure
plot(lambda1)

A(1) = sum(lambda1(1:spikeindex(1)))
for i = 2:N
    A(i) = sum(lambda1(spikeindex(i-1):spikeindex(i)));
end
[eCDF, zvals] = ecdf(A);
mCDF = 1-exp(-zvals);
figure
plot(mCDF, eCDF);
hold on
plot([0 1], [0 1]+1.36/sqrt(N), 'k') %why is this the confidence bound?
plot([0 1], [0 1]-1.36/sqrt(N), 'k')
hold off
xlabel('Model CDF')
ylabel('Emperical CDF')
title('model 1: only vel')

2
%model 2: vel and vel^2
b2 = glmfit([vel vel.^2], trains, 'poisson')
lambda2 = exp(b2(1)+b2(2)*vel+b2(3)*vel.^2);

figure
plot(lambda2)

Z(1) = sum(lambda2(1:spikeindex(1)));
for i = 2:N
    Z(i) = sum(lambda2(spikeindex(i-1):spikeindex(i)));
end
[eCDF, zvals] = ecdf(Z);
mCDF = 1-exp(-zvals);
figure
plot(mCDF, eCDF)
hold on
plot([0 1], [0 1]+1.36/sqrt(N), 'k') %why is this the confidence bound?
plot([0 1], [0 1]-1.36/sqrt(N), 'k')
hold off
xlabel('Model CDF')
ylabel('Emperical CDF')
title('model 2: vel and vel^2')

3
%model 3: only acc
b3 = glmfit(acc, trains, 'poisson')
lambda3 = exp(b3(1)+b3(2)*acc);
figure
plot(lambda3)
Z(1) = sum(lambda3(1:spikeindex(1)));
for i = 2:N
    Z(i) = sum(lambda3(spikeindex(i-1):spikeindex(i)));
end
[eCDF, zvals] = ecdf(Z);
mCDF = 1-exp(-zvals);
figure
plot(mCDF, eCDF)
hold on
plot([0 1], [0 1]+1.36/sqrt(N), 'k') %why is this the confidence bound?
plot([0 1], [0 1]-1.36/sqrt(N), 'k')
hold off
xlabel('Model CDF')
ylabel('Emperical CDF')
title('model 3: only acc')

4
%model 4: acc and acc^2
b4 = glmfit([acc acc.^2], trains, 'poisson')
lambda4 = exp(b4(1)+b4(2)*acc+b4(3)*acc.^2);
figure
plot(lambda4)

Z(1) = sum(lambda4(1:spikeindex(1)));
for i = 2:N
    Z(i) = sum(lambda4(spikeindex(i-1):spikeindex(i)));
end
[eCDF, zvals] = ecdf(Z);
mCDF = 1-exp(-zvals);
figure
plot(mCDF, eCDF)
hold on
plot([0 1], [0 1]+1.36/sqrt(N), 'k') %why is this the confidence bound?
plot([0 1], [0 1]-1.36/sqrt(N), 'k')
hold off
xlabel('Model CDF')
ylabel('Emperical CDF')
title('model 4: acc and acc^2')

5
%model 5: acc & vel
b5 = glmfit([vel acc], trains, 'poisson')
lambda5 = exp(b5(1)+b5(2)*vel+b5(3)*acc);
figure
plot(lambda5)
Z(1) = sum(lambda5(1:spikeindex(1)));
for i = 2:N
    Z(i) = sum(lambda5(spikeindex(i-1):spikeindex(i)));
end
[eCDF, zvals] = ecdf(Z);
mCDF = 1-exp(-zvals);
figure
plot(mCDF, eCDF)
hold on
plot([0 1], [0 1]+1.36/sqrt(N), 'k') %why is this the confidence bound?
plot([0 1], [0 1]-1.36/sqrt(N), 'k')
hold off
xlabel('Model CDF')
ylabel('Emperical CDF')
title('model 5: acc & vel')

6
%model 6: vel, vel^2, acc, acc^2
b6 = glmfit([vel acc vel.^2 acc.^2], trains, 'poisson')
lambda6 = exp(b6(1)+b6(2)*vel+b6(3)*acc+b6(4)*vel.^2+b6(5)*acc.^2); %i think
figure
plot(lambda6)
Z(1) = sum(lambda6(1:spikeindex(1)));
for i = 2:N
    Z(i) = sum(lambda6(spikeindex(i-1):spikeindex(i)));
end
[eCDF, zvals] = ecdf(Z);
mCDF = 1-exp(-zvals);
figure
plot(mCDF, eCDF)
hold on
plot([0 1], [0 1]+1.36/sqrt(N), 'k') %why is this the confidence bound?
plot([0 1], [0 1]-1.36/sqrt(N), 'k')
hold off
xlabel('Model CDF')
ylabel('Emperical CDF')
title('model 6: vel, vel^2, acc, acc^2')

7
%model 7: abs acc
b7 = glmfit(abs(acc), trains, 'poisson')
lambda7 = exp(b7(1)+b7(2)*abs(acc));
figure
plot(lambda7)
Z(1) = sum(lambda3(1:spikeindex(1)));
for i = 2:N
    Z(i) = sum(lambda7(spikeindex(i-1):spikeindex(i)));
end
[eCDF, zvals] = ecdf(Z);
mCDF = 1-exp(-zvals);
figure
plot(mCDF, eCDF)
hold on
plot([0 1], [0 1]+1.36/sqrt(N), 'k') %why is this the confidence bound?
plot([0 1], [0 1]-1.36/sqrt(N), 'k')
hold off
xlabel('Model CDF')
ylabel('Emperical CDF')
title('model 7: abs acc')

8
%model 7: abs acc
b8 = glmfit([vel acc abs(acc)], trains, 'poisson')
lambda8 = exp(b8(1)+b8(2)*vel+b8(3)*acc+b8(4)*abs(acc));
figure
plot(lambda8)
Z(1) = sum(lambda8(1:spikeindex(1)));
for i = 2:N
    Z(i) = sum(lambda8(spikeindex(i-1):spikeindex(i)));
end
[eCDF, zvals] = ecdf(Z);
mCDF = 1-exp(-zvals);
figure
plot(mCDF, eCDF)
hold on
plot([0 1], [0 1]+1.36/sqrt(N), 'k') %why is this the confidence bound?
plot([0 1], [0 1]-1.36/sqrt(N), 'k')
hold off
xlabel('Model CDF')
ylabel('Emperical CDF')
title('model 7: abs acc')
