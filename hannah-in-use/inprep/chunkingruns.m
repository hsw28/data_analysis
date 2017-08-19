function f = chunkingruns(pos)

%chunks data into run number and then place in run, returns structure of elements


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
yposs = abs(360-ypos);

while i<=size(runnum,1)
		%finds start times in range -- this is when the rat is at the end of forced choice arm
		if i<size(runnum,1)
			timeranges = find(tme>runnum(i) & tme<runnum(i+1));
			%finds x when on correct side
			xranges = find(xpos<500);
			both = intersect(xranges, timeranges);
			both = both';
			%finds most extreme y
			[value, index] = (max(yposs(both)));
			index = index + both(1);
		elseif i == size(runnum,1)
			timeranges = find(pos(:,1)>runnum(i) & pos(:,1)<max(tme));
			xranges = find(xpos<500);
			both = intersect(xranges, timeranges);
			both = both';
			%finds most extreme y
			[value, index] = (max(yposs(both)));
			index = index + both(1);
		  end

%add times to matrix
timestart(end+1) = index;
i = i+1;
end

% matrix of all start times
starttimes = [tme(timestart)];

k=2;
while k <=length(starttimes)
		runtimes = find (tme < starttimes(k) & tme > starttimes(k-1));
		runtimes(1);
		runtimes(end);
		x = xpos(runtimes);
		y = ypos(runtimes);
		times = tme(runtimes);

		%find INDEX of points in forced arms
		xforce = find(x<460);
		%assign these to points so now you have values instead of data
		timeforce = times(xforce);

		%find INDEX of points in middle arm
		xmid = find(x>461 & x<850);
		ymid = find(y>300 & y<400);
		%find indices that appear in both
		bothindex = intersect(xmid, ymid);
		%assign these to points so now you have values instead of data
		timemiddle = times(bothindex);

		%find INDEX of points in reward arm
		xreward = find(x>850);
		%assign these to points so now you have values instead of data
		timereward = times(xreward);

		name = char('trial_');
		trialnum = (k-1);
		name = strcat(name, int2str(trialnum));
		forcename = strcat(name, '_forced');
		midname = strcat(name, '_middle');
		rewname = strcat(name, '_reward');

		myStruct.(forcename) = timeforce';
	  myStruct.(midname) = timemiddle';
	  myStruct.(rewname) = timereward';

		k = k+1;

end


f = myStruct;
