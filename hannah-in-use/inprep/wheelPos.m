function f = wheelPos(wheelpos)

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
withinmeanIndex = find(abs(RfromPointsMean-diffrommean) < 2*RfromPointsSTD); %we keep these points
wheelposgood = wheelposgood(withinmeanIndex, :);

% extrapolate points to 30 hrtz sampling frequency (might want to do more later)

% linearize:
% refind equation in case it changed with extrapolation (check to see if we need to do this)
% shift everything so center is 0,0 (just subtract x and y)
% use tangent to find the angle of every coordinate pair
%BOOM
