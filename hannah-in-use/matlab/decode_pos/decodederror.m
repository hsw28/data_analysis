function f = decodederror(decoded, pos, decodedinterval)
%returns an error in cm for each decoded time
%decodedinterval is the length of decoding, for ex .5 for half a second

pos = fixpos(pos);

if size(decoded,1)>size(decoded,2)
  decoded = decoded';
end


pointstime = decoded(4,:);
X = decoded(1,:);
Y = decoded(2,:);

decin = decodedinterval*30;



vel = velocity(pos);
%vel(1,:) = smoothdata(vel(1,:), 'gaussian', 3);
vel = vel(1,:);

alldiffmean = [];
movediffmean = [];
stilldiffmean = [];
velvalue = 0;
velvector = [];
alldiff = [];
movediff = [];
stilldiff = [];
numpoints = [];



%vel = assignvelOLD(pointstime, vel);


realX = [];
realY = [];
realT = [];
predX = [];
predY = [];
predT = [];
realV = [];
for i=1:length(decoded)

  curtime = pointstime(i)+(decodedinterval/2);
  %postimes = find(pos(:,1)>=(pointstime(i)-decodedinterval/2) & pos(:,1)<(pointstime(i)+decodedinterval/2));



  [c index] = min(abs(curtime-pos(:,1)));
  decinB = round(min(decin, index-1));
  decinC = round(min(decin, length(vel)-index-1));

  %if mean(vel(index-decinB:index+decinC))>velabove
  if isnan(X(i))==0 & isnan(Y(i))==0

    pairs = [X(i),Y(i);(pos(index,2)),(pos(index,3))];
    diff = pdist(pairs,'euclidean');
  else
    diff = NaN;
  end


    alldiff(end+1) = diff;
    %numpoints(end+1) = c;
    realX(end+1) = nanmean(pos(index,2));
    realY(end+1) = nanmean(pos(index,3));
    realT(end+1) = nanmean(pos(index,1));
    %realV(end+1) = nanmean(vel(postimes,1))
    predX(end+1) = X(i);
    predY(end+1) = Y(i);
    predT(end+1) = pointstime(i);




end

mean(alldiff)./3.5

%f = [predT; predX; predY; realT; realX; realY; realV]';
f = [alldiff/3.5; realT];
