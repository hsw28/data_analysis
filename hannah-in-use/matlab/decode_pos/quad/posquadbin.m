function f = posquadbin(timevector, posData, tdecode, decodedmat)
%puts actual time into quadrants so you can compare data from firingPerPosQuad


t = tdecode;
t = 2000*t;

threshold = 12;

mintime = min(posData(:,1));
maxtime = max(posData(:,1));
oldtime = posData(:,1);
X = (posData(:,2));
Y = (posData(:,3));

newX = interp1(oldtime, X, timevector, 'pchip');
newY = interp1(oldtime, Y, timevector, 'pchip');
posData = [timevector; newX; newY]';
vel = velocity(posData);
vel(1,:) = smoothdata(vel(1,:), 'gaussian', 10);
vel = vel(1,:);
X = (posData(:,2));
Y = (posData(:,3));

%defiding position
%         [ 1   2   3   4   5   6   7   8   9   10  11]
xlimmin = [320 320 320 320 320 440 638 750 780 828 780 780];
xlimmax = [505 450 440 505 505 638 828 950 950 950 950 950];
ylimmin = [545 422 320 170 000 300 300 575 420 339 182 000];
ylimmax = [700 545 422 320 170 440 440 700 575 420 339 182];

times = [];
tm = 1;
avX = [];
avY = [];
newvel = [];
velcount = [];
while tm < (length(timevector)-t)
  avX(end+1) = mean(X(tm:tm+t));
  avY(end+1) = mean(Y(tm:tm+t));
  times(end+1) = timevector(tm);
  velcount(end+1) = length(find((vel(tm:tm+t))>threshold));
  %newvel(end+1) = mean(vel(tm:tm+t));

    tm = tm+t;

end



quad = zeros(length(times), 1);
for k=1:length(xlimmin)
  inX = find(avX > xlimmin(k) & avX<=xlimmax(k));
  inY = find(avY > ylimmin(k) & avY<=ylimmax(k));
  inboth = intersect(inX, inY);
  quad(inboth) = k;
end

actualquad = [];
decodequad = [];
newtimes = [];
goodX = [];
goodY = [];
for n = 1:length(quad)
  %if newvel(n) > threshold
  if velcount(n) >= .66*t
    actualquad(end+1) = quad(n);
    decodequad(end+1) = decodedmat(1,n);
    newtimes(end+1) = times(n);
    goodX(end+1) = avX(n);
    goodY(end+1) = avY(n);
  end
end

%f = velcount;
con = confusionmat(actualquad, decodequad);
figure
plotconfusion(categorical(actualquad), categorical(decodequad));
figure
plotConfMat(con);


f = [actualquad', decodequad', newtimes', goodX',goodY'];
