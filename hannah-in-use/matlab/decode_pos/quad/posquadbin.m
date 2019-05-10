function [forcedarms, forcedpoint, middle, choicearms, freepoint] = posquadbin(posData, rippletimes)
%outputs start and end times animal is in each quadrant



threshold = 6;

mintime = min(posData(:,1));
maxtime = max(posData(:,1));
oldtime = posData(:,1);
X = (posData(:,2));
Y = (posData(:,3));
times = (posData(:,1));

vel = velocity(posData);
vel(1,:) = smoothdata(vel(1,:), 'gaussian', 10);
vel = vel(1,:);

%defiding position
%         [ 1   2   3   4   5   6   7   8   9   10  11]
xlimmin = [300 300 320 320 320 450 750 780 828 780 780];
xlimmax = [505 450 450 505 505 850 950 950 950 950 950];
ylimmin = [545 422 320 170 000 300 575 420 339 182 000];
ylimmax = [700 545 422 320 170 440 700 575 420 339 182];

  %position 1: end of left forced
  %position 2: left forced
  %position 3: forced choice point
  %position 4: right forced
  %position 5: end of right forced
  %position 6: middle stem
  %position 7: end of left choice
%position 8 left choice arm
%position 9: free choice point
%position 10: right choice arm
%position 11: end of right choice arm

%2 and 4 grouped as forced arms
%3 is forced point
%6 is middle stem
%8 and 10 grouped as choice arms
%9 is free choice point


forcedarms = [];
forcedpoint = [];
middle = [];
choicearms = [];
freepoint = [];
quad = zeros(length(times), 1);
for k=1:length(xlimmin)

  inX = find(X > xlimmin(k) & X <=xlimmax(k));
  inY = find(Y > ylimmin(k) & Y <=ylimmax(k));
  inboth = intersect(inX, inY);
  for z=1:length(inboth)
    if length(rippletimes)<1
      rippletimes=0;
    end
    [cc indexmin] = min(abs(times(inboth(z))-rippletimes));
    ripdif = abs(times(inboth(z))-rippletimes(indexmin));
    if (k == 2 | k== 4) & ripdif>.5           %& vel(inboth(z))>threshold
      forcedarms(end+1) = times(inboth(z));
    elseif k == 3 & ripdif>.5                                     %& vel(inboth(z))>threshold
      forcedpoint(end+1) = times(inboth(z));
    elseif k == 6 & ripdif>.5                                     %& vel(inboth(z))>threshold
        middle(end+1) = times(inboth(z));
    elseif (k == 8 | k== 10) & ripdif>.5                           %& vel(inboth(z))>threshold
        choicearms(end+1) = times(inboth(z));
    elseif k == 9 & ripdif>.5                                     %& vel(inboth(z))>threshold
        freepoint(end+1) = times(inboth(z));
    end
  end
end

%%%%%%%%%%%%

%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
runnum = forcedarms(1);
index = 1;
i=2;
while i <= length(forcedarms)
		if forcedarms(i)-forcedarms(i-1) > 3
				runnum(end+1) = forcedarms(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = forcedarms(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end

%then add the finishing point
runnum(end+1) = forcedarms(end);

% check to make sure every foray into the middle is >.5 seconds like (takes ~2 seconds to run through middle)
i = 2;
while i <=size(runnum,2)
	 if runnum(i)-runnum(i-1) < .1
		  runnum(i) = 0;
			runnum(i-1) = 0;
		end
	i = i+2;
end

%delete all elemts with zero
forcedarms = runnum(runnum~=0);
forcedarms = forcedarms';

%%%%%%%

%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
runnum = forcedpoint(1);
index = 1;
i=2;

while i <= length(forcedpoint)
		if forcedpoint(i)-forcedpoint(i-1) > 3
				%index(end+1) = i-1;
				%index(end+1) = i;
				runnum(end+1) = forcedpoint(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = forcedpoint(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end

%then add the finishing point
runnum(end+1) = forcedpoint(end);

% check to make sure every foray into the middle is >.5 seconds like (takes ~2 seconds to run through middle)
i = 2;
while i <=size(runnum,2)
	 if runnum(i)-runnum(i-1) < .1
		  runnum(i) = 0;
			runnum(i-1) = 0;
		end
	i = i+2;
end

%delete all elemts with zero
forcedpoint = runnum(runnum~=0);
forcedpoint = forcedpoint';

%%%%%%%%%%

%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
runnum = middle(1);
index = 1;
i=2;
while i <= length(middle)
		if middle(i)-middle(i-1) > 3
				%index(end+1) = i-1;
				%index(end+1) = i;
				runnum(end+1) = middle(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = middle(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end

%then add the finishing point
runnum(end+1) = middle(end);

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
middle = runnum(runnum~=0);
middle = middle';

%%%%%%%%%%

%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
runnum = choicearms(1);
index = 1;
i=2;
while i <= length(choicearms)
		if choicearms(i)-choicearms(i-1) > 3
				%index(end+1) = i-1;
				%index(end+1) = i;
				runnum(end+1) = choicearms(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = choicearms(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end

%then add the finishing point
runnum(end+1) = choicearms(end);

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
choicearms = runnum(runnum~=0);
choicearms = choicearms';

%%%%%%%%%%%%%

%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
runnum = freepoint(1);
index = 1;
i=2;
while i <= length(freepoint)
		if freepoint(i)-freepoint(i-1) > 3
				%index(end+1) = i-1;
				%index(end+1) = i;
				runnum(end+1) = freepoint(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = freepoint(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end

%then add the finishing point
runnum(end+1) = freepoint(end);

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
freepoint = runnum(runnum~=0);
freepoint = freepoint';
