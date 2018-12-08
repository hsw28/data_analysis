function f = plotheatdecoding2(decodedpos, decodedvel, decodedtime, delay)
%plots decoded point againt actual animal position in a nice little video
%if dont have actual position put 0 for posData
%delay can either be a single value or a vector of velocities
%YOU CAN MAKE IT NOT PLOT IF VELOCITY IS UNDER A CERTAIN AMOUNT. SEE CODE

limitedmatrix = decodedpos;
pointstime  = decodedtime;

posData = zeros(length(decodedtime), 3);

vel = decodedvel(1,:);

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

  posX = decodedpos(1,:);
  max(posX)
  posY = decodedpos(2,:);
  max(posY)

colors = zeros(3,length(vel));
%crange = [min(vel) max(vel)];
crange = [4 50];
for n=1:length(vel)
  colors(:,n)= vals2colormap(vel(n), 'parula', crange);
end


numtimes = [];
f=1
figure
for i=1:length(posX)
    clf
    axis([200 1000 0 700]);
    rectangle('Position', [posX(i) posY(i) 35 35], 'FaceColor',colors(:,i))
    %imagesc([posX(i); posY(i); vel(i)], [min(vel) max(vel)])
    hold on

    %else %
    %imagesc(limitedmatrix(:,:,i)', [1 2]) %
    %hold on %
    %end %

    %axis xy
    str1 = {'Frame' i };
    t = text(2,2,str1, 'r');
    t.FontSize = 12;
    t.Color = 'red';
    M(i) = getframe;
    hold off
    %if length(delay)==1
    %    fr = delay*100;
    %    M(f:(f+fr)) = getframe;
        pause(delay)
    %    f = f+fr;
    %end
    i
end

video = VideoWriter('822remdecode.avi')
video.FrameRate = 10;
open(video);


writeVideo(video, M);
