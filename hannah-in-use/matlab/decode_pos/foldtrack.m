function [fold foldlin] = foldtrack(pos)


x = pos(:,2);
y = pos(:,3);
xmin = min(x);
xmax = max(x);
ynew = y;

xbins = ceil(xmax-xmin./5);
xstart= xmin;
ydefault = 375;
for k=1:xbins
  xwant = find(x>=xstart & x<(xstart+10)); %go through x step by step
  ywant = y(xwant); %find y in x area
  ynum = find(ywant>=350 & ywant<=400); %find y in center of x area
  ymean = mean(ywant(ynum)); %find the mean of that y
  if isnan(ymean) == 1
    ynew(xwant) =  abs(y(xwant)-ydefault);
  else
    ydefault = ymean;
    ynew(xwant) =  abs(y(xwant)-ymean);
  end

  xstart = xstart+10;
end

fold = [pos(:,[1,2]), ynew];
scatter(fold(:,2),fold(:,3));

%linearizing

yarms = find(ynew > 30);
xarms = find(x<500 | x>775);
arms = intersect(yarms, xarms);

ycenter = find(ynew<=30);
ycentermin = min(y(ycenter));
ycentermax = max(y(ycenter));
xcentermin = min(x(ycenter));
xcentermax = max(x(ycenter));




for k = 1:length(arms)

  curval = arms(k);
  if x(curval) <500
    xcentermin-abs(ynew(curval)-ycentermin);
    x(curval) = xcentermin-abs(ynew(curval)-ycentermin);
  else
    x(curval) = xcentermax+abs(ynew(curval)-ycentermax);
  end
end


foldlin = [pos(:,[1]), x, ynew];
foldlin(:,3) = 300;
