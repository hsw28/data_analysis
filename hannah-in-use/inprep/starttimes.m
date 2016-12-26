function t = starttimes(pos)

%finds time animal starts each trial and returns a matrix of all start times and index values
% output is [index of start, start time]
% may want to add in trial end also


tme = pos(:,1);
tme = tme';
xpos = pos(:,2);
xpos = xpos';
ypos = pos(:,3);
ypos = ypos';

%find INDEX of points in forced arms
xend = find(xpos<460);
yend = find(ypos<350 | ypos>370);
%find indices that appear in both
bothindex = intersect(xend, yend);
%assign these to points
timeend = tme(bothindex);
xend = xpos(bothindex);
yend = ypos(bothindex);

timeend = timeend';
runnum = [];
runnum(end+1)= timeend(1);
i = 2;
%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
while i <= size(timeend,1)
		timeend(i);
		timeend(i-1);
		if timeend(i)-timeend(i-1) > 1
				runnum(end+1) = timeend(i);
		end
i=i+1;
end


%now you have a matrix of all the times where rat first enters forced arm.
% have to find max location on the force arm during that entrance
%this gives you the trial start
i= 1;
runnum = runnum';
timestart= [];
xstart = [];
ystart = [];
ypos = abs(360-ypos);

while i<=size(runnum,1)
		%finds times in range
		if i<size(runnum,1)
			timeranges = find(tme>runnum(i) & tme<runnum(i+1));
			%finds x when on correct side
			xranges = find(xpos<460);
			both = intersect(xranges, timeranges);
			both = both';
			%finds most extreme y
			[value, index] = (max(ypos(both(1):both(end))));
			index = index + both(1);
			%yranges = find(max(abs(360-(ypos(min(timeranges):max(timeranges))))))
		elseif i == size(runnum,1)
			timeranges = find(pos(:,1)>runnum(i) & pos(:,1)<max(tme));
			xranges = find(xpos<460);
			both = intersect(xranges, timeranges);
			both = both';
			%finds most extreme y
			[value, index] = (max(ypos(both(1):both(end))));
			index = index + both(1);
		  end
%add times to matrix
timestart(end+1) = index;
i = i+1;
end


t = [timestart; tme(timestart)];
