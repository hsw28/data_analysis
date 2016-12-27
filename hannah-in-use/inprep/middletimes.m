function f = middletimes(pos);
	% getting too many points now (like ones that dont fit the x bounds) but i need ZZZzzzz
%finds start and stop times for travelling in middle arm (they alternate)

tme = pos(:,1);
tme = tme';
xpos = pos(:,2);
xpos = xpos';
ypos = pos(:,3);
ypos = ypos';

%find INDEX of points in middle
xmid = find(xpos>500 & xpos<800);
%ymiddle = find(ypos>350 & ypos<370);
%find indices that appear in both
%bothindex = intersect(xmiddle, ymiddle);
%assign these to points
timemiddle = tme(xmid)
xmiddle = xpos(xmid);
ymiddle = ypos(xmid);



%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
runnum = timemiddle(1);
index = 1;
i=2;
while i <= size(timemiddle,2)
		if timemiddle(i)-timemiddle(i-1) > 2
				index(end+1) = i-1;
				index(end+1) = i;
				runnum(end+1) = timemiddle(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = timemiddle(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end


f = [index; runnum];
