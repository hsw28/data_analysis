function [velbin1, velbin2, velbin3, velbin4, velbin5, velbin6] = velbintimes(posData, rippletimes)
%outputs start and end times animal is in each quadrant


mintime = min(posData(:,1));
maxtime = max(posData(:,1));
oldtime = posData(:,1);
X = (posData(:,2));
Y = (posData(:,3));
times = (posData(:,1));

vel = velocity(posData);
vel(1,:) = smoothdata(vel(1,:), 'gaussian', 10);
times = vel(2,:);
vel = vel(1,:);


%defiding position
%         [ 1   2   3   4   5   6   7   8   9   10  11]
vbin = [0 7 14 21 28 35];


velbin1 = [];
velbin2 = [];
velbin3 = [];
velbin4 = [];
velbin5 = [];
velbin6 = [];
quad = zeros(length(times), 1);
for k=1:length(vbin)
  if k<length(vbin)
  vindex = find(vel>=vbin(k) & vel<vbin(k+1));
  elseif k==length(vbin)
  vindex = find(vel>=vbin(k));
  end
  for z=1:length(vindex)
    if length(rippletimes)<1
      rippletimes=0;
    end
    [cc indexmin] = min(abs(times(vindex(z))-rippletimes));
    ripdif = abs(times(vindex(z))-rippletimes(indexmin));
    if k ==2
      velbin1(end+1) = times(vindex(z));
    elseif k == 3
      velbin2(end+1) = times(vindex(z));
    elseif k == 4
      velbin3(end+1) = times(vindex(z));
    elseif k == 5
      velbin4(end+1) = times(vindex(z));
    elseif k == 6
      velbin5(end+1) = times(vindex(z));
    elseif k == 7
      velbin6(end+1) = times(vindex(z));
    end
  end
end


%%%%%%%%%%%%

%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
if length(velbin1)<1
  velbin1 = NaN;
end
runnum = velbin1(1);
index = 1;
i=2;
while i <= length(velbin1)
		if velbin1(i)-velbin1(i-1) > 3
				runnum(end+1) = velbin1(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = velbin1(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end

%then add the finishing point
runnum(end+1) = velbin1(end);

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
velbin1 = runnum(runnum~=0);
velbin1 = velbin1';

%%%%%%%

%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
if length(velbin2)<1
  velbin2 = NaN;
end
runnum = velbin2(1);
index = 1;
i=2;

while i <= length(velbin2)
		if velbin2(i)-velbin2(i-1) > 3
				%index(end+1) = i-1;
				%index(end+1) = i;
				runnum(end+1) = velbin2(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = velbin2(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end

%then add the finishing point
runnum(end+1) = velbin2(end);

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
velbin2 = runnum(runnum~=0);
velbin2 = velbin2';

%%%%%%%%%%

%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
if length(velbin3)<1
  velbin3 = NaN;
end
runnum = velbin3(1);
index = 1;
i=2;
while i <= length(velbin3)
		if velbin3(i)-velbin3(i-1) > 3
				%index(end+1) = i-1;
				%index(end+1) = i;
				runnum(end+1) = velbin3(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = velbin3(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end

%then add the finishing point
runnum(end+1) = velbin3(end);

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
velbin3 = runnum(runnum~=0);
velbin3 = velbin3';

%%%%%%%%%%

%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
if length(velbin4)<1
  velbin4 = NaN;
end
runnum = velbin4(1);
index = 1;
i=2;
while i <= length(velbin4)
		if velbin4(i)-velbin4(i-1) > 3
				%index(end+1) = i-1;
				%index(end+1) = i;
				runnum(end+1) = velbin4(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = velbin4(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end

%then add the finishing point
runnum(end+1) = velbin4(end);

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
velbin4 = runnum(runnum~=0);
velbin4 = velbin4';

%%%%%%%%%%%%%

%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
if length(velbin5)<1
  velbin5 = NaN;
end
runnum = velbin5(1);
index = 1;
i=2;
while i <= length(velbin5)
		if velbin5(i)-velbin5(i-1) > 3
				%index(end+1) = i-1;
				%index(end+1) = i;
				runnum(end+1) = velbin5(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = velbin5(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end

%then add the finishing point
runnum(end+1) = velbin5(end);

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
velbin5 = runnum(runnum~=0);
velbin5 = velbin5';


%%%%%%%

%now can seperate into runs basically based on the amount of time between points
%adds the first time point after a lapse to runnum matrix
if length(velbin6)<1
  velbin6 = NaN;
end
runnum = velbin6(1);
index = 1;
i=2;
while i <= length(velbin6)
		if velbin6(i)-velbin6(i-1) > 3
				%index(end+1) = i-1;
				%index(end+1) = i;
				runnum(end+1) = velbin6(i-1);  %this is the last point that the animal is in the middle
				runnum(end+1) = velbin6(i); %this is the first point the animal reenters the middle
		end
i=i+1;
end

%then add the finishing point
runnum(end+1) = velbin6(end);

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
velbin6 = runnum(runnum~=0);
velbin6 = velbin6';
