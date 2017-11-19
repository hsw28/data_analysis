function f = wheelwrap(degree)
  % input degree data from wheelPOS.m and it wraps it all up

wrappedRAD = (unwrap(deg2rad(degree(:,2))));
wrappedDEG = rad2deg(wrappedRAD);

f = [degree(:,1) wrappedDEG];
