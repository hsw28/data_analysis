function f = plotpoints(decoded, pos)
%plots decoded point againt actual animal position in a nice little video

  pointstime = decoded(4,:);
  X = decoded(1,:);
  Y = decoded(2,:);



figure
for i=1:length(X)
    [c index] = (min(abs(pointstime(i)-pos(:,1))));
    plot(pos(index,2), pos(index,3), 'or','MarkerSize',5,'MarkerFaceColor','b')
    hold on
    plot(X(i),Y(i),'or','MarkerSize',5,'MarkerFaceColor','r')
    axis([min(pos(:,2))-10 max(pos(:,2))+10 min(pos(:,3))-10 max(pos(:,3))+10])
    pause(5)
    hold off
    i
end
