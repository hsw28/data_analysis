function f = velposcompare(decodedvel, posXYnotime)
%input velocities (such as  decoded velocities), it bins them into low, medium, and high
%and tells you the pos distribution of locations for each velocity
%your decodedvel and pos must use the same indexing
%your post must be entered as XY without time

comparething = posXYnotime;

if size(comparething, 1) > size(comparething, 2)
  comparething = comparething';
end

if length(decodedvel)>length(comparething)
decodedvel = decodedvel(:, 1:length(comparething));
elseif length(decodedvel)<length(comparething)
comparething = comparething(:,1:length(decodedvel));
end

%decodedtime = decodedvel(2,:);
decodedvel = decodedvel(1,:);
vbin = [0; 5; 10; 15; 20; 25]

numinbin = length(vbin)/3;
indexlowbin = find(decodedvel< vbin(1+numinbin));
indexmidbin = find(decodedvel >= vbin(1+numinbin) & decodedvel < vbin(1+2*numinbin));
indexhighbin = find(decodedvel>= vbin(1+2*numinbin));


lowcompare = comparething(:, indexlowbin);
midcompare = comparething(:, indexmidbin);
highcompare = comparething(:, indexhighbin);


v.low = lowcompare;
v.mid = midcompare;
v.high = highcompare;

meanlow = mean(lowcompare);
meanmid = mean(midcompare);
meanhigh = mean(highcompare);
std(lowcompare)./sqrt(length(lowcompare));
std(midcompare)./sqrt(length(midcompare));
std(highcompare)./sqrt(length(highcompare));

%state 1: left forced end
%state 2: left forced arm
%state 3: right forced arm
%state 4: right forced end
%state 5: first half (by forced) middle arm -- will be an elseif on the ys   x<645
%state 6: second half (by reward) middle arm -- will be an elseif on the ys  x>=645
%state 7: left reward end     x >= 780  y>=575
%state 8: left reward arm     x >=780   y<575 y>411
%state 9: right reward arm    x >=780   y>=172  y<370
%state 10: right reward end   x >=780   y<172


lowcompare = comparething(:, indexlowbin);
midcompare = comparething(:, indexmidbin);
highcompare = comparething(:, indexhighbin);


for j=1:3
  statecount = [];
  if j == 1
  x = lowcompare(1,:);
  y = lowcompare(2,:);
  elseif j ==2
  x = midcompare(1,:);
  y = midcompare(2,:);
  elseif j ==3
  x = highcompare(1,:);
  y = highcompare(2,:);
  end
for k=1:length(x)
  if x(k)< 517 & y(k)>=557
    statecount(end+1) = 1;
  %2
  elseif x(k)< 517 &  y(k)>= 410 & y(k)< 557
    statecount(end+1) = 2;
  %3
  elseif x(k) < 517 & y(k) < 353 & y(k) >= 183
    statecount(end+1) = 3;
  %4
  elseif x(k)< 517 & y(k) < 183
    statecount(end+1) = 4;
  %7
elseif x(k) >= 797 & y(k)>=586
    statecount(end+1) = 7;
  %8
elseif x(k) >=797  & y(k)< 586 & y(k)> 428
    statecount(end+1) = 8;
  %9
elseif x(k) >=797  & y(k)>=131  & y(k)< 387 % 180 if reg pos, 131 if decode
    statecount(end+1) = 9;
  %10
elseif x(k) >=797 & y(k)< 131 %180 if reg pos, 131 if decode
    statecount(end+1) = 10;
    %5
  elseif x(k)< 662
    statecount(end+1) = 5;
    %6
  elseif x(k)>=662
    statecount(end+1) = 6;
  end

  if j == 1
    lowhist = statecount;
  elseif j ==2
    midhist = statecount;
  elseif j ==3
    highhist = statecount;
  end

end
end

%f = v;
f = highhist;

figure
subplot(1,3,1);
%histogram(lowhist, 'BinWidth', 1, 'Normalization','probability')
histogram(lowhist, 'Normalization','probability')

subplot(1,3,2)
histogram(midhist, 'Normalization','probability')
subplot(1,3,3)
histogram(highhist, 'Normalization','probability')



%figure
%subplot(1,3,1);
%histogram(v.low(2,:), 'BinWidth', 35, 'Normalization','probability')
%subplot(1,3,2)
%histogram(v.mid(2,:), 'BinWidth', 35, 'Normalization','probability')
%subplot(1,3,3)
%histogram(v.high(2,:), 'BinWidth', 35, 'Normalization','probability')




[meanlow, meanmid, meanhigh];
