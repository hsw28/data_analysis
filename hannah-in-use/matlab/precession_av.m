function f = precession_av(precdata)

%precdata should be a matrix of [X, phase]

X = precdata(1,:);
phase = precdata(2,:);

[X,I] = sort(X);
X = X./3.5; %convert to cm
phase = phase(I);

k = X(1);
avphase = [];
Xval = [];
while k<=X(end)-1 %bin in 1cm
  [cc indexmin] = min(abs(k-X));
  [cc indexmax] = min(abs((k+.000001)-X)); %+.1 for .1cm
  avphase(end+1) = nanmean(phase(indexmin:indexmax));
  Xval(end+1) = k;
  k = k+1;
end

%f = [Xval avphase];
figure
scatter(Xval, avphase)
