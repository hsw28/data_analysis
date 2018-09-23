function f = decodeerror(decoded, pos)
%returns an error in cm for each decoded time

pointstime = decoded(4,:);
X = decoded(1,:);
Y = decoded(2,:);


alldiffmean = [];
movediffmean = [];
stilldiffmean = [];
velvalue = 0;
velvector = [];
alldiff = [];
movediff = [];
stilldiff = [];

for i=1:length(decoded)
  [c index] = (min(abs(pointstime(i)-pos(:,1))));
  diff = hypot(X(i)-pos(index,2), Y(i)-pos(index, 3));
  alldiff(end+1) = diff;
end

f = [alldiff/3.5; pointstime];
