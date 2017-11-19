function [degrees xycoord] = wheelPos(wheelpos, time)
% input position data of wheel tracker and time. cleans up wheel data and interpolates data for all time points
% returns two arrays-- position by degrees and xy position
%
%function [degrees xycoord] = wheelPos(wheelpos, time)


%eliminate erroneous position points-- seems like these usually happen when the LED is be blocked by the animal
%does this by finding indices of values that make sense and keeping those
goodvalindex = find(wheelpos(:,2)<800);
wheelposgood = wheelpos(goodvalindex, :);

%find upper ~2/3 of points that aren't obscured by the animal
toppointsindex = find(wheelposgood(:,3)>250);
toppoints = wheelposgood(toppointsindex, :);

%fit all the points to a circle
[xc yc R] = circfit(toppoints(:,2),toppoints(:,3));

%finds points that are far from the circle equation
% predicts radius given all points
RfromPoints = sqrt(((wheelposgood(:,2)-xc).^2)+((wheelposgood(:,3)-yc).^2));
% finds mean/median of predicted radius (dont know which is better so using both)
RfromPointsMean = (mean(RfromPoints)+median(RfromPoints))/2;
%finds difference from the mean of each set of points
diffrommean = zeros([length(RfromPoints) 1]);
diffrommean = RfromPoints-RfromPointsMean;
%finds std dev of RfromPoints and indices of points that are < 2 stddevs from mean
RfromPointsSTD = std(RfromPoints);
withinmeanIndex = find(abs(diffrommean) < (2*RfromPointsSTD)); %we keep these points
wheelposgood = wheelposgood(withinmeanIndex, :);



% make sure all time values are unique
[C,ia,ic] = unique(wheelposgood(:,1));
wheelposgood = wheelposgood(ia,:);

% start time when position data starts
timeindex = find(time>= wheelposgood(1,1) & time<=wheelposgood(end,1));
time = time(timeindex);

% extrapolate x values
extrapX = interp1(wheelposgood(:,1),wheelposgood(:,2),time);
extrapY = interp1(wheelposgood(:,1),wheelposgood(:,3),time);


% linearize:
% refind equation in case it changed with extrapolation
[xc yc R] = circfit(extrapX,extrapY);

% shift everything so center is 0,0 (just subtract x and y)
extrapX = extrapX-xc;
extrapY = extrapY-yc;




% use inverse tangent to find the angle of every coordinate pair
k =1;
angles = zeros(length(time), 1);
while k <= length(time)
    ang = abs(atand(extrapY(k)/extrapX(k)));
    if extrapX(k)>=0 & extrapY(k)>=0
      angles(k) = ang;
    elseif extrapX(k)<0 & extrapY(k)>=0
      angles(k) = 180-ang;
    elseif extrapX(k)<0 & extrapY(k)<0
      angles(k) = 180+ang;
    elseif extrapX(k)>=0 & extrapY(k)<0
      angles(k) = 360-ang;
    end
    k = k+1;
end

% returns degree array
degrees = [time', angles];
% returns xy coords
xcoord = cosd(angles)*R;
ycoord = sind(angles)*R;
xycoord = [time', xcoord, ycoord];
