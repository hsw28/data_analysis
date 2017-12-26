function f = glmTEST(spiketimes, vel, acc)


%what is the format of vel entered? all times? spike times only? vector or matrix?

N = length(spiketimes);

%model 1: only vel
b1 = glmfit(vel, spiketrain, 'poisson');
lambda1 = exp(b1(1)+b1(2)*vel);

Z(1) = sum(lamda1(1:spikeindex(1)));
for i = 2:N
    Z(i) = sum(lambda1(spikeindex(i-1):spikeindex(i)));
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
title('model 1: only vel')


%model 2: vel and vel^2
b2 = glmfit([vel vel.^2], spiketrain, 'poisson');
lambda2 = exp(b2(1)+b2(2)*vel+b2(3)*vel.^2);

Z(1) = sum(lamda2(1:spikeindex(1)));
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


%model 3: only acc
b3 = glmfit(acc, spiketrain, 'poisson');
lambda3 = exp(b3(1)+b3(2)*acc);

Z(1) = sum(lamda3(1:spikeindex(1)));
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


%model 4: acc and acc^2
b4 = glmfit([acc acc.^2], spiketrain, 'poisson');
lambda4 = exp(b4(1)+b4(2)*acc+b4(3)*acc.^2);

Z(1) = sum(lamda4(1:spikeindex(1)));
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


%model 5: acc & vel
b5 = glmfit([vel acc], spiketrain, 'poisson');
lambda1 = exp(b5(1)+b5(2)*vel+b5(2)*acc); %i think, or could be lambda1 = exp(b5(1)+b5(2)*vel+b5(3)*acc)

Z(1) = sum(lamda5(1:spikeindex(1)));
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


%model 6: vel, vel^2, acc, acc^2
b6 = glmfit([vel vel.^2 acc acc.^2], spiketrain, 'poisson');
lambda1 = exp(b6(1)+b6(2)*vel+b6(2)*acc+b6(3)*vel.^2+b2(3)*acc.^2); %i think

Z(1) = sum(lamda6(1:spikeindex(1)));
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
