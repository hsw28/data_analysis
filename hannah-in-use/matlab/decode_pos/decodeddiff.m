function f = decodeddiff(decoded, pos)
%determines the average amount of error at above different velocities.
%outputs a histogram of error distance at each velocity and a matrix of average error against velocity

  pointstime = decoded(4,:);
  X = decoded(1,:);
  Y = decoded(2,:);



vel = velocity(pos);
length(find(vel(1,:)<10))
f = vel;

alldiffmean = [];
movediffmean = [];
stilldiffmean = [];
velvalue = 0;
velvector = [];

while velvalue <=60
alldiff = [];
movediff = [];
stilldiff = [];
for i=1:length(decoded)
    [c index] = (min(abs(pointstime(i)-pos(:,1))));
    diff = hypot(X(i)-pos(index,2), Y(i)-pos(index, 3));
    alldiff(end+1) = diff;
    if index<=length(vel) & vel(1, index) > velvalue
      movediff(end+1) = diff;
    elseif index<=length(vel) & vel(1, index) <= velvalue
      stilldiff(end+1) = diff;
    end
end

alldiffmean(end+1) = mean(alldiff)/3.5;
alldifferror = std(alldiff)/sqrt(length(alldiff))/3.5;
movediffmean(end+1) = mean(movediff)/3.5;
movedifferror = std(movediff)/sqrt(length(movediff))/3.5;
stilldiffmean(end+1) = mean(stilldiff)/3.5;
stilldifferror = std(stilldiff)/sqrt(length(stilldiff))/3.5;
velvector(end+1) = velvalue;
if velvalue == 0 | velvalue == 10 | velvalue == 20 | velvalue == 30 | velvalue == 40 | velvalue == 50 | velvalue == 60

  subplot(2,4,velvalue/10+1);
  histogram(movediff/3.5, 'Normalization', 'probability', 'BinWidth', 25)
  axis([0 250 0 .4])
  xlabel('Error in cm')
  ylabel('Percent')
end
velvalue = velvalue+5;
end

f = [velvector; movediffmean];
