function f = wheelRUN(wheeldegrees);
%input wheel degree vector from wheelPos
% finds sin and smooths over areas where the rat isn't running
% outputs smoothed function

SINwheel = wheeldegrees;
SINwheel(:,2) = sind(wheeldegrees(:,2));
[pks,pkindex] = findpeaks(SINwheel(:,2),'MinPeakWidth', .5);
[valleys,valindex] = findpeaks(SINwheel(:,2)*(-1), 'MinPeakWidth', .5);

extremeINDEX = vertcat(pkindex, valindex);
extremeINDEX = sort(extremeINDEX);

k = 2;
nonrunning = [];
while k < length(extremeINDEX)
    if SINwheel(extremeINDEX(k),2) > .9 | SINwheel(extremeINDEX(k),2) < .1
      k = k+1;
    elseif SINwheel(extremeINDEX(k-1),2) > .9 | SINwheel(extremeINDEX(k-1),2) < .1 | SINwheel(extremeINDEX(k+1),2) > .9 | SINwheel(extremeINDEX(k+1),2) < .1
      k = k+1;
    else
       nonrunning(end+1) = (k); %this is all the indices of low maxima/minima from extreme index
       k = k+1;
     end
end

oneD = SINwheel(:,2);

k = 1;

while k <= length(nonrunning)
    z = 0;
    while nonrunning(k)+z == nonrunning(k+z) & k+z<length(nonrunning)
      z = z+1;
    end
    if z>=1
    av = mean(oneD((extremeINDEX(nonrunning(k))):extremeINDEX(nonrunning(k+z-1))));
    oneD((extremeINDEX(nonrunning(k))):extremeINDEX(nonrunning(k+z-1))) = av;
    k = k+z;
    else
      k=k+1;
    end
  end

  f = [SINwheel(:,1), oneD];
