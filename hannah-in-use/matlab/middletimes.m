function [toreward, awayreward, all] = middletimes(pos, whatpartofmiddle);
%finds start and stop times for travelling in middle arm
%returns two vectors-- times going toward reward and times away
%
% for what part of track:
% 1 = full middle arm
% 2 = first half of middle arm
% 3 = second half of middle arm

tme = pos(:,1);
pos = assignpos([tme(1):.1:tme(end)], pos);
tme = pos(:,1);
tme = tme';
xpos = pos(:,2);
xpos = xpos';
ypos = pos(:,3);
ypos = ypos';


%find INDEX of points in middle
if whatpartofmiddle == 1
		xmid = find(xpos>450 & xpos<840); %FOR MIDDLE ARM FULL
elseif whatpartofmiddle == 2
		xmid = find(xpos>450& xpos<650); %FOR MIDDLE ARM FIRST HALF
elseif whatpartofmiddle == 3
		xmid = find(xpos>650 & xpos<840); %FOR MIDDLE ARM SECOND HALF
end
ymiddle = find(ypos>330 & ypos<420);
%find indices that appear in both
bothindex = intersect(xmid, ymiddle);
%assign these to points
timemiddle = tme(bothindex);
xmiddle = xpos(bothindex);
ymiddle = ypos(bothindex);

all = [timemiddle; xmiddle; ymiddle];


%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
runnum = timemiddle(1);
index = 1;
i=2;
xcoord = xmiddle(1);
while i <= size(timemiddle,2)
		if timemiddle(i)-timemiddle(i-1) > 3

				%index(end+1) = i-1;
				%index(end+1) = i;
				xcoord(end+1) = xmiddle(i-1);
				xcoord(end+1) = xmiddle(i);
				runnum(end+1) = timemiddle(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = timemiddle(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end
%then add the finishing point
runnum(end+1) = timemiddle(end);
xcoord(end+1) = xmiddle(end);
%all = xcoord;



% check to make sure every foray into the middle is >.5 seconds like (takes ~2 seconds to run through middle)
i = 2;
while i <=size(runnum,2)
	 if runnum(i)-runnum(i-1) < .5 | abs(xcoord(i)-xcoord(i-1))<300
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
	[cc startmid] = min(abs(mids(i-1)-tme));
	[cc endmid] = min(abs(mids(i)-tme));
	if xpos(endmid)-xpos(startmid) > 0 %towards reward
			toreward(end+1) = tme(startmid);
			toreward(end+1) = tme(endmid);
	else
		awayreward(end+1) = tme(startmid);
		awayreward(end+1) = tme(endmid);
	end
i=i+2;
end
