function f= goaltimes(pos);

%finds start and end times the rat is in the goal box
%not perfect, needs to be checked against pos data

tme = pos(:,1);
tme = tme';
xpos = pos(:,2);
xpos = xpos';
ypos = pos(:,3);
ypos = ypos';

%find INDEX of points in goalboxes
xgoal = find(xpos>800 & xpos<950);
ygoal = find(ypos>566 | ypos<154);
goal = intersect(xgoal, ygoal);
%assign values
timegoal = tme(goal);
xgoal = xpos(goal);
ygoal = ypos(goal);

%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
runnum = timegoal(1);
index = 1;
i=2;
while i <= size(timegoal,2)
		if goal(i)-goal(i-1) > 40
				%index(end+1) = i-1;
				%index(end+1) = i;
				runnum(end+1) = timegoal(i-1);  %this is the last point that the animal is in the box
				runnum(end+1) = timegoal(i); %this is the first point the animal reenters the box
		end
i=i+1;
end
%then add the finishing point
runnum(end+1) = timegoal(end);

f = runnum;


%{
yleft = find(ypos>566); %left goal box
yright = find(ypos<154); %right goal box

%find indices that appear in both
leftpoints = intersect(xgoal, yleft);
rightpoints = intersect(xgoal, yright);

%assign these to points for left box
timeleft = tme(leftpoints);
xgoalleft = xpos(leftpoints);
ygoalleft = ypos(leftpoints);
% and for right box
timeright = tme(rightpoints);
xgoalright = xpos(rightpoints);
ygoalright = ypos(rightpoints);
%}
