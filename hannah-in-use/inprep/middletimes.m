function [toreward, awayreward] = middletimes(pos);
%finds start and stop times for travelling in middle arm
%returns two vectors-- times going toward reward and times away

tme = pos(:,1);
tme = tme';
xpos = pos(:,2);
xpos = xpos';
ypos = pos(:,3);
ypos = ypos';

%find INDEX of points in middle
%xmid = find(xpos>450 & xpos<850); %FOR MIDDLE ARM FULL
xmid = find(xpos>450& xpos<650); %FOR MIDDLE ARM FIRST HALF
%xmid = find(xpos>650 & xpos<850); %FOR MIDDLE ARM SECOND HALF
ymiddle = find(ypos>350 & ypos<370);
%find indices that appear in both
bothindex = intersect(xmid, ymiddle);
%assign these to points
timemiddle = tme(bothindex);
xmiddle = xpos(bothindex);
ymiddle = ypos(bothindex);




%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
runnum = timemiddle(1);
index = 1;
i=2;
while i <= size(timemiddle,2)
		if timemiddle(i)-timemiddle(i-1) > 3
				%index(end+1) = i-1;
				%index(end+1) = i;
				runnum(end+1) = timemiddle(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = timemiddle(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end
%then add the finishing point
runnum(end+1) = timemiddle(end);

% check to make sure every foray into the middle is >.5 seconds like (takes ~2 seconds to run through middle)
i = 2;
while i <=size(runnum,2)
	 if runnum(i)-runnum(i-1) < .4 | runnum(i)-runnum(i-1) > 8
		  runnum(i) = 0;
			runnum(i-1) = 0;
		end
	i = i+2;
end

%delete all elemts with zero
mids = runnum(runnum~=0);
mids = mids';
tme = tme';
xpos = xpos';

%now find direction of animal
i=2;
toreward = [];
awayreward = [];
while i <=size(mids,1)
	startmid = find(abs(mids(i-1)-tme)<.001);
	endmid = find(abs(mids(i)-tme)<.001);
	if xpos(endmid)-xpos(startmid) > 0 %towards reward
			toreward(end+1) = tme(startmid);
			toreward(end+1) = tme(endmid);
	else
		awayreward(end+1) = tme(startmid);
		awayreward(end+1) = tme(endmid);
	end
i=i+2;
end
