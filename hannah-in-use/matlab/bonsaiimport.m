function [pos hd] = bonsaiimport(timestamps, bonsaiCSV)
  bonsaiCSV = bonsaiCSV(1:length(timestamps),:);
X = mean(bonsaiCSV(:,[1,3]), 2);
Y = mean(bonsaiCSV(:,[2,4]), 2);

X = X(1:length(timestamps));
Y = Y(1:length(timestamps));
xy = [timestamps, X, Y];

 nanindex = find(~isnan(xy(:,2)) | ~isnan(xy(:,3)));
 pos = xy(nanindex, :);


%head direction
x1 = bonsaiCSV(:,1);
y1 = bonsaiCSV(:,2);
x2 = bonsaiCSV(:,3);
y2 = bonsaiCSV(:,4);

hd = atan2d(y2,x2) - atan2d(y1,x1);
hd = [timestamps, hd]';
nanindex = find(~isnan(hd(2,:)));
hd = hd(:,nanindex);
