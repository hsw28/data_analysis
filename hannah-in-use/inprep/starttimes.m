function t = starttimes(pos)

%finds time animal starts each trial and returns a matrix of all start & end times and index values
% start times are the time the animal is at the end of the forced arms
%end times are when the animal finishes at the choice arm (and is about to go down the center stem to the forced arm)
% output alternates between start and end times
% so to analyze data you would want to do overlapping pairs: (a,b), the (b,c), then (c,d), etc
% output is [start time]
%
% can plug into cohereruns.m to get coherence for runs

% may want to add in trial end also


tme = pos(:,1);
tme = tme';
xpos = pos(:,2);
xpos = xpos';
ypos = pos(:,3);
ypos = ypos';

%find INDEX of points in forced arms
xend = find(xpos<460);
yend = find(ypos<300 | ypos>400);
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
		if timeend(i)-timeend(i-1) > 2
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
		%finds start times in range -- this is when the rat is at the end of forced choice
		if i<size(runnum,1)
			timeranges = find(tme>runnum(i) & tme<runnum(i+1));
			%finds x when on correct side
			xranges = find(xpos<500);
			both = intersect(xranges, timeranges);
			both = both';
			%finds most extreme y
			[value, index] = (max(ypos(both)));
			index = index + both(1);
		elseif i == size(runnum,1)
			timeranges = find(pos(:,1)>runnum(i) & pos(:,1)<max(tme));
			xranges = find(xpos<500);
			both = intersect(xranges, timeranges);
			both = both';
			%finds most extreme y
			[value, index] = (max(ypos(both)));
			index = index + both(1);
		  end
	%finds "end times" -- this is when rat finishes going to choice arms for the last times
%{
	if i<size(runnum,1)
		%finds x when on correct side
		timeranges = find(tme>runnum(i) & tme<runnum(i+1))
		xranges = find(xpos>800);
		both = intersect(xranges, timeranges);
		both = both';
		%finds most extreme y
		[endvalue, endindex] = (findpeaks(ypos(both)));
		endindex = endindex(end) + both(1);
	elseif i == size(runnum,1)
		xranges = find(xpos>800);
		both = intersect(xranges, timeranges);
		both = both';
		%finds most extreme y
		[endvalue, endindex] = (findpeaks(ypos(both)));
		endindex = endindex(end) + both(1);
		end
%}
%add times to matrix
timestart(end+1) = index;
%timestart(end+1) = endindex;
i = i+1;
end


t = [tme(timestart)];
