function f = assignpos(time, posData)




mintime = min(posData(:,1));
maxtime = max(posData(:,1));
oldtime = posData(:,1);
X = (posData(:,2));
Y = (posData(:,3));

[c indexmin] = (min(abs(time-mintime)));
[c indexmax] = (min(abs(time-maxtime)));
time = time(indexmin:indexmax);

[oldtime,ia,ic] = unique(oldtime);

newX = interp1(unique(oldtime), X(ia), time, 'pchip');
newY = interp1(unique(oldtime), Y(ia), time, 'pchip');
posData = [time; newX; newY]';

f = posData;
