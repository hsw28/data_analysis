function t = starttimes(pos)

%finds time animal starts each trial
% may want to add in trial end also


tme = pos(:,1);
tme = tme';
xpos = pos(:,2);
xpos = xpos';
ypos = pos(:,3);
ypos = ypos';

%find INDEX of points in forced arms
xend = find(xpos<460);
yend = find(ypos<350 & ypos>370);
%find indices that appear in both
bothindex = intersect(xend, yend);
%assign these to points
timeend = tme(bothindex);
xend = xpos(bothindex);
yend = ypos(bothindex);

runnum = [timeend(i)];
i = 2;
%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
while i <= size(timeend)
		if timeend(i)-timeend(i-1) > 1
				runnum(end+1) = timeend(1);
		end
i=i+1;
end

%now you have a matrix of all the times where rat first enters forced arm.
% have to find max location on the force arm during that entrance
%this gives you the trial start
i= 1;
timestart= [];
xstart = [];
ystart = [];
while i<=size(runnum)
		%finds times in range
		if i<size(runnum)
			timeranges = find(pos(:,1)>runnum(i) & pos(:,1)<runnum(i+1));
			%finds X
			xranges = find(max(pos(min(timeranges):max(timeranges), 2)));
			yranges = find(max(abs(360-(pos(min(timeranges):max(timeranges), 3)))));
			bothindex = intersect(xranges, yranges)
		elseif i = size(runnum)
			timeranges = find(pos(:,1)>runnum(i) & pos(:,1)<max(tme));
			%finds X
			xranges = find(max(pos(min(timeranges):max(timeranges), 2)));
			yranges = find(max(abs(360-(pos(min(timeranges):max(timeranges), 3)))));
			bothindex = intersect(xranges, yranges)
		end
%add times to matrix
timestart(end+1) = tme(bothindex);
xstart(end+1) = xpos(bothindex);
ystart(end+1) = ypos(bothindex);
i = i+1;
end

t = timestart;
