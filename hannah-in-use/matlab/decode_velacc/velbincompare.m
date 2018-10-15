function f = velbincompare(decodedvel, comparething)

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
vbin = [0; 6; 12; 18; 24; 30];

numinbin = length(vbin)/3;

indexlowbin = find(decodedvel< vbin(1+numinbin));
indexmidbin = find(decodedvel >= vbin(1+numinbin) & decodedvel < vbin(1+2*numinbin));
indexhighbin = find(decodedvel>= vbin(1+2*numinbin));

%forcrosstab = zeros(length(decodedvel), 1);
%forcrosstab(indexlowbin) = 1;
%forcrosstab(indexmidbin)= 2;
%forcrosstab(indexhighbin) = 3;

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


f = v;
figure
subplot(1,3,1);
histogram(v.low(1,:), 'BinWidth', 35, 'Normalization','probability')
subplot(1,3,2)
histogram(v.mid(1,:), 'BinWidth', 35, 'Normalization','probability')
subplot(1,3,3)
histogram(v.high(1,:), 'BinWidth', 35, 'Normalization','probability')

figure
subplot(1,3,1);
histogram(v.low(2,:), 'BinWidth', 35, 'Normalization','probability')
subplot(1,3,2)
histogram(v.mid(2,:), 'BinWidth', 35, 'Normalization','probability')
subplot(1,3,3)
histogram(v.high(2,:), 'BinWidth', 35, 'Normalization','probability')




[meanlow, meanmid, meanhigh];
