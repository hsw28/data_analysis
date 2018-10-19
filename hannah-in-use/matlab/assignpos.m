function f = assignpos(time, posData)




mintime = min(posData(:,1));
maxtime = max(posData(:,1));
oldtime = posData(:,1);
X = (posData(:,2));
Y = (posData(:,3));

[c indexmin] = (min(abs(time-mintime)));
[c indexmax] = (min(abs(time-maxtime)));
time = time(indexmin:indexmax);


newX = interp1(oldtime, X, time, 'pchip');
newY = interp1(oldtime, Y, time, 'pchip');
posData = [time; newX; newY]';

f = posData;
