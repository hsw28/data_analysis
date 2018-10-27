function f = plotpoints(decoded, pos, delay)
%plots decoded point againt actual animal position in a nice little video

if size(decoded,1)>size(decoded,2)
  decoded = decoded';
end


  pointstime = decoded(4,:);
  X = decoded(1,:);
  Y = decoded(2,:);


%figure
for i=1:length(X)
  if length(pos)>1
    [c index] = (min(abs(pointstime(i)-pos(:,1))));
    plot(pos(index,2), pos(index,3), 'or','MarkerSize',5,'MarkerFaceColor','b')
    hold on
    plot(X(i),Y(i),'or','MarkerSize',5,'MarkerFaceColor','r')
    axis([min(pos(:,2))-10 max(pos(:,2))+10 min(pos(:,3))-10 max(pos(:,3))+10])
    str1 = {'Frame' i };
    text(600,350,str1);
    M(i) = getframe;
    pause(delay)
    %hold off
  else
    plot(X(i),Y(i),'or','MarkerSize',5,'MarkerFaceColor','r')
    axis([300 1000 0 700])
    str1 = {'Frame' i };
    text(600,350,str1);
    pause(delay)
  end
    i
end

%video = VideoWriter('vidtest.avi')
%video.FrameRate = 2;
%open(video);

%writeVideo(video, M);
