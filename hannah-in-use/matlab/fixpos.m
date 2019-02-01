function f = fixpos(pos)

file = pos';

t = file(1, :);
xpos = (file(2, :))';
%movmedian
xpos = filloutliers(xpos, 'pchip', 'movmedian',5);
ypos = (file(3, :))';
ypos = filloutliers(ypos, 'pchip', 'movmedian',5);
t = t(1:length(xpos));


pos = [t', xpos, ypos];
file = pos;
newtime = t(1):1/30:t(end);
file = assignpos(newtime, file);

f = file;
