function [toreward1, awayreward1, toreward2, awayreward2, toreward3, awayreward3] = middletimes3(pos);
%finds start and stop times for travelling in middle arm, with arm split into thirds
%returns two vectors-- times going toward reward and times away


tme = pos(:,1);
tme = tme';
xpos = pos(:,2);
xpos = xpos';
ypos = pos(:,3);
ypos = ypos';

%find INDEX of points in middle
  %xmid =  find(xpos>450 & xpos<(850));
	xmid1 = find(xpos>450 & xpos<(583)); %FOR MIDDLE ARM SECOND HALF
	xmid2 = find(xpos>=(583.33) & xpos<716);
  xmid3 = find(xpos>=(716.66) & xpos<850);


ymiddle = find(ypos>330 & ypos<420);
%find indices that appear in both
bothindex1 = intersect(xmid1, ymiddle);
bothindex2 = intersect(xmid2, ymiddle);
bothindex3 = intersect(xmid3, ymiddle);
%assign these to points
timemiddle1 = tme(bothindex1);
xmiddle1 = xpos(bothindex1);
ymiddle1 = ypos(bothindex1);

timemiddle2 = tme(bothindex2);
xmiddle2 = xpos(bothindex2);
ymiddle2 = ypos(bothindex2);

timemiddle3 = tme(bothindex3);
xmiddle3 = xpos(bothindex3);
ymiddle3 = ypos(bothindex3);

timemiddle = padcat(sort(timemiddle1), sort(timemiddle2), sort(timemiddle3));



%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
runnum = timemiddle(1);
index = 1;
i=2;
zz = 1;
for zz=1:size(timemiddle,1)
runnum = timemiddle(zz,1);
while i <= length(find(isnan(timemiddle(zz,:))==0))
		if timemiddle(zz,i)-timemiddle(zz,i-1) > 3
				%index(end+1) = i-1;
				%index(end+1) = i;
				runnum(end+1) = timemiddle(zz,i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = timemiddle(zz,i); %this is the first point the animal reenters the middle
		end
i=i+1;
end

%then add the finishing point
runnum(end+1) = timemiddle(zz,end);
% check to make sure every foray into the middle is >.5 seconds like (takes ~2 seconds to run through middle)
i = 2;
while i <=size(runnum,2)
	 if runnum(i)-runnum(i-1) < .1 | runnum(i)-runnum(i-1) > 5
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
if zz == 1
toreward1 = [];
awayreward1 = [];
while i <=size(mids,1)
	[cc startmid] = min(abs(mids(i-1)-tme));
  [cc endmid] = min(abs(mids(i)-tme));
	if xpos(endmid)-xpos(startmid) > 0 & endmid>startmid  %towards reward
			toreward1(end+1) = tme(startmid);
			toreward1(end+1) = tme(endmid);
	elseif xpos(endmid)-xpos(startmid) < 0 & endmid>startmid
		awayreward1(end+1) = tme(startmid);
		awayreward1(end+1) = tme(endmid);
	end
i=i+2;
end
end

i=2;
if zz == 2
toreward2 = [];
awayreward2 = [];
while i <=size(mids,1)
  [cc startmid] = min(abs(mids(i-1)-tme));
  [cc endmid] = min(abs(mids(i)-tme));
	if xpos(endmid)-xpos(startmid) > 0 & endmid>startmid %towards reward
			toreward2(end+1) = tme(startmid);
			toreward2(end+1) = tme(endmid);
	elseif xpos(endmid)-xpos(startmid) < 0 & endmid>startmid
		awayreward2(end+1) = tme(startmid);
		awayreward2(end+1) = tme(endmid);
	end
i=i+2;
end
end

i=2;
if zz == 3
toreward3 = [];
awayreward3 = [];
while i <=size(mids,1)
  [cc startmid] = min(abs(mids(i-1)-tme));
  [cc endmid] = min(abs(mids(i)-tme));



	if xpos(endmid)-xpos(startmid) > 0 & endmid>startmid %towards reward
			toreward3(end+1) = tme(startmid);
			toreward3(end+1) = tme(endmid);
	elseif xpos(endmid)-xpos(startmid) < 0 & endmid>startmid
		awayreward3(end+1) = tme(startmid);
		awayreward3(end+1) = tme(endmid);
	end
i=i+2;
end
end

end

length(toreward1);
length(awayreward1);
length(toreward2);
length(awayreward2);
length(toreward3);
length(awayreward3);
