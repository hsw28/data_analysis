function f = plotheatdecoding(decodedmatrix, decodedtime, posData, delay)
%plots decoded point againt actual animal position in a nice little video
%if dont have actual position put 0 for posData

limitedmatrix = decodedmatrix;
pointstime  = decodedtime;

if posData ==0
  posData = zeros(length(decodedtime), 3);
end

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


figure
for i=1:length(limitedmatrix)
    if posData(1,1) ==0
      axis([1 size(limitedmatrix,1) 1 size(limitedmatrix,2)])
    else
      axis([min(posData(:,2)) max(posData(:,2)) min(posData(:,3)) max(posData(:,3))])
    end
    colormap(bone)
    imagesc(limitedmatrix(:,:,i)', [0 .5])
    hold on
    [c index] = (min(abs(pointstime(i)-posData(:,1))));
    axis xy
    plot(posData(index, 2), posData(index, 3), 'or','MarkerSize',5,'MarkerFaceColor','r')
    hold off
    pause(delay)
    %hold off
    i
end
