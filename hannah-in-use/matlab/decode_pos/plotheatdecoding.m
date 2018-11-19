function f = plotheatdecoding(decodedmatrix, decodedtime, posData, delay)
%plots decoded point againt actual animal position in a nice little video
%if dont have actual position put 0 for posData
%delay can either be a single value or a vector of velocities
%YOU CAN MAKE IT NOT PLOT IF VELOCITY IS UNDER A CERTAIN AMOUNT. SEE CODE

limitedmatrix = decodedmatrix;
pointstime  = decodedtime;

if posData ==0
  posData = zeros(length(decodedtime), 3);
end

vel = velocity(posData);
vel = vel(1,:);


psize = 3.5 * 10;
xmin = min(posData(:,2))
ymin = min(posData(:,3))
xmax = max(posData(:,2))
ymax = max(posData(:,3))
xbins = ceil((xmax-xmin)/psize); %number of x
ybins = ceil((ymax-ymin)/psize); %number of y
  timecells = zeros(xbins, ybins); %used to be time
  events = zeros(xbins,ybins);
  xstep = xmax/xbins;
  ystep = ymax/ybins;
  tstep = 1/30;


  xinc = xmin +(0:xbins)*psize; %makes a vectors of all the x values at each increment
  yinc = ymin +(0:ybins)*psize;

for x = (1:xbins) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
  for y = (1:ybins)
      if x<xbins & y<ybins
        inX = find(posData(:,2)>=xinc(x) & posData(:,2)<xinc(x+1));
        posData(inX,2) = x;
        inY = find(posData(:,3)>=yinc(y) & posData(:,3)<yinc(y+1));
        posData(inY,3) = y;
      elseif x==xbins & y<ybins
        inX = find(posData(:,2)>=xinc(x))
        posData(inX,2) = x;
        inY = find(posData(:,3)>=yinc(y) & posData(:,3)<yinc(y+1));
        posData(inY,3) = y;
      elseif x<xbins & y==ybins
        inX = find(posData(:,2)>=xinc(x) & posData(:,2)<xinc(x+1));
        posData(inX,2) = x;
        inY = find(posData(:,3)>=yinc(y))
        posData(inY,3) = y;
      elseif x==xbins & y==ybins
        inX = find(posData(:,2)>=xinc(x))
        posData(inX,2) = x;
        inY = find(posData(:,3)>=yinc(y))
        posData(inY,3) = y;
      end
    end
end

f=1
figure
for i=1:length(pointstime)
    if posData(1,1) ==0
      axis([0 size(limitedmatrix,1)+1 0 size(limitedmatrix,2)+1])
    else
      axis([min(posData(:,2))-1 max(posData(:,2))+1 min(posData(:,3))-1 max(posData(:,3))+1])
    end
    colormap(bone)
    %imagesc(zeros(size(limitedmatrix,1), size(limitedmatrix,2)))
    [c index] = (min(abs(pointstime(i)-posData(:,1))));

    %commend lines out marked with % if you dont want to screen for velocity
    %if mean(vel(index-10:index+10))>13    %
    imagesc(limitedmatrix(:,:,i)', [0 .88])
    hold on
    %else %
    %imagesc(limitedmatrix(:,:,i)', [1 2]) %
    %hold on %
    %end %

    [c index] = (min(abs(pointstime(i)-posData(:,1))));
    axis xy
    plot(posData(index, 2), posData(index, 3), 'or','MarkerSize',5,'MarkerFaceColor','r')
    str1 = {'Frame' i };
    t = text(2,2,str1, 'r');
    t.FontSize = 12;
    t.Color = 'red';
    M(i) = getframe;
    hold off
    if length(delay)==1
        fr = delay*100;
        M(f:(f+fr)) = getframe;
        pause(delay)
        f = f+fr;
    else
        currentdelay = 2./delay(i);
        M(f:f+ceil(currentdelay*10)) = getframe;
        pause(currentdelay)
    end
    %hold off
    i
end

video = VideoWriter('decodetrack2018-08-10.avi')
video.FrameRate = 6;
open(video);

writeVideo(video, M);
