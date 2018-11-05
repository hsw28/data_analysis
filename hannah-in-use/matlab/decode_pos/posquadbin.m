function f = posquadbin(timevector, posData, tdecode)
%puts actual time into quadrants so you can compare data from firingPerPosQuad


t = tdecode;
t = 2000*t;


mintime = min(posData(:,1));
maxtime = max(posData(:,1));
oldtime = posData(:,1);
X = (posData(:,2));
Y = (posData(:,3));

newX = interp1(oldtime, X, timevector, 'pchip');
newY = interp1(oldtime, Y, timevector, 'pchip');
posData = [timevector; newX; newY]';
X = (posData(:,2));
Y = (posData(:,3));

%defiding position
xlimmin = [320 320 320 320 320 460 750 780 835 780 780];
xlimmax = [505 505 460 505 505 835 950 950 950 950 950];
ylimmin = [548 410 315 127 000 300 556 415 334 187 000];
ylimmax = [700 548 410 315 127 440 700 556 415 334 187];

times = [];
tm = 1;
avX = [];
avY = [];
while tm < (length(timevector)-t)
  avX(end+1) = mean(X(tm:tm+t));
  avY(end+1) = mean(Y(tm:tm+t));
  times(end+1) = timevector(tm);
  if tdecode>=.25
    tm = tm+(t/2);
  else
    tm = tm+t;
  end
end



quad = zeros(length(times), 1);
for k=1:length(xlimmin)
  inX = find(avX > xlimmin(k) & avX<=xlimmax(k));
  inY = find(avY > ylimmin(k) & avY<=ylimmax(k));
  inboth = intersect(inX, inY);
  quad(inboth) = k;
end


f = [quad'; times];
