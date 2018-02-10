function f = glmTEST3(cluster, time, pos)


clustsize = length(cluster);
[c timestart] = min(abs(time-pos(1,1)));
[c timeend] = min(abs(pos(end,1)-time));
time = time(timestart:timeend);

vel = noiselessVelocity(pos);
vel = assignvel(time, vel);
time = vel(2,:);
vel = vel(1,:);



acc = accelfromvel(vel, time);
acc = acc(1,:);


posX = [pos(:,2), pos(:,1)]; %[xpos, time]
posX = assignvel(time,posX');
posX = posX(1,:);

posY = [pos(:,2), pos(:,1)]; %[xpos, time]
posY = assignvel(time,posY');
posY = posY(1,:);

moveind = find(vel>21);
moving = zeros(1, length(vel));
moving(moveind) = 1;

accind = find(acc > 9 | acc < -9);
acceling = zeros(1, length(acc));
acceling(accind) = 1;

vel = vel(2:end-2);
time = time(2:end-2);
posX = posX(2:end-2);
posY = posY(2:end-2);
moving = moving(2:end-2);


vel = vel';
vel2 = vel.^2;
acc = acc';
acc2 = acc.^2;
posX = posX';
posY = posY';
moving = moving';
acceling = acceling';

%UN COMMENT IF YOU WANT DIRECTION
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
spikeindex = find(trains);
N = length(spikeindex);


% testing with spike data and vel only
ord = 100;
t0 = length(time);
t1 = t0-ord; %update number of time time points
y = reshape(trains(ord+1:end)', t1, 1);
Ivel = reshape(vel(ord+1:end)', t1, 1);
Iacc = reshape(acc(ord+1:end)', t1, 1);
IposX = reshape(posX(ord+1:end)', t1, 1);
%Idir = reshape(dir(ord+1:end)', t1, 1); %direction
Imoving = reshape(moving(ord+1:end)', t1, 1);
Iacceling = reshape(acceling(ord+1:end)', t1, 1);
Ivel2 = reshape(vel2(ord+1:end)', t1, 1);
Iacc2 = reshape(acc2(ord+1:end)', t1, 1);

xHist = [];
for i = 1:ord

    xHist = [xHist reshape(trains(ord+1-i:end-i)', t1, 1)];

end

f = xHist;

%model 1: only vel
size(Ivel);
size(xHist);
%[b1,dev,stats] = glmfit([Ivel Iacc IposX Idir Imoving Iacceling xHist], y, 'poisson');
%[b1,dev,stats] = glmfit([Ivel Iacc Iacceling xHist], y, 'poisson');
%[b1,dev,stats] = glmfit([Ivel Iacc IposX Imoving Iacceling xHist], y, 'poisson');
[b1,dev,stats] = glmfit([Ivel Iacc Ivel2 Iacc2 xHist], y, 'poisson');



%b1 = glmfit([Ivel], y, 'poisson')
% Ivel Iacc IposX Idir Imoving Iacceling xHist
b1

Ivel_p = stats.p(2)
Iacc_p = stats.p(3)
Ivel2_p = stats.p(4)
Iacc2_p = stats.p(5)
%IposX_P = stats.p(4)
%Idir_P = stats.p(5)
%Imoving_P = stats.p(5)
%Iacceling_P = stats.p(6)
IxHist_P = stats.p(6:end)

% history effects and p values

figure
subplot(211)
plot(1:ord, exp(b1(6:end)))
ylabel('Modulation')
xlabel('Lag [ms]')
subplot(212)
plot(1:ord, -log(stats.p(6:end))) %plot p values
hold on
plot([1 ord], [-log(.05) -log(.05)]); %p value thresholds
ylabel('log p-value, above line is significant')
xlabel('Lag (ms)')
hold off


%lambda1 = exp(b1(1)+b1(2)*Ivel+b1(3)*Iacc+b1(4)*IposX+b1(5)*xHist);
lambda1 = exp(b1(1)+b1(2)*Ivel+b1(3)*Iacc+b1(4)*Ivel2+b1(5)*Iacc2 + b1(6)*xHist);

%figure
%bar(binning(time, 200), binning(trains, 200), 20);
%hold on
%binned = binning(exp(b1(1)+b1(2)*Ivel+b1(3)*Iacc+b1(4)*IposX+b1(5)*Idir+b1(6)*Imoving)*10, 200);
%plot(binning(time, 200), binned, 'LineWidth', 2);
%hold off


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

R = cumsum(stats.resid);
figure
plot(R);
title('resid cumsum')


%figure
%plot(mCDF)
%title('model CDF')
%figure
%plot(eCDF)
%title('Emperical CDF')
