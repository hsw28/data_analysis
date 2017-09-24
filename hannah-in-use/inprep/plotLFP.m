function f = plotLFP(lfpstructure, time)

if size(time,1)<size(time,2)
  time = time';
end

figure
hold on
k=1;
while k<=size(lfpstructure,2)
  f = plot(time, lfpstructure(:,k)+k);
  k=k+1;
end
