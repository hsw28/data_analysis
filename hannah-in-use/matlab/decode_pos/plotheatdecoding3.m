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
crange = [-6 46];
for n=1:length(vel)
  colors(:,n)= vals2colormap(vel(n), 'parula', crange);
end

numvec = zeros(length(posX),2);
for lx=1:length(posX)

  for ly=1:length(posY)

    ix = find(posX==posX(lx));
    iy = find(posY==posY(ly));
    ixy = intersect(ix,iy);
    numvec(ixy,1) = length(ixy);
    numvec(ixy,2) = (1:length(ixy));

  end
end

numtimes = [];
f=1
figure
axis([200 1000 0 700]);
order = randperm(length(posX));
for k=1:length(posX)

    i = order(k);
    blocknum = numvec(i,1);
    %blocksize = 35./(numvec(i,1)^(1/numvec(i,1)));
    %blockshiftsize = 35./(numvec(i,1)^(1/numvec(i,1)));
    blockshift = numvec(i,2);


    if blocknum >1
      vec = (9:.1:ceil(blocknum)*2+12);
      length(vec)
      ranshift = randperm(length(vec));
      if rem(ranshift(1),2)==0
        nowposX = posX(i)-vec(ranshift(1));
      elseif rem(ranshift(1),2)~=0
        nowposX = posX(i)+vec(ranshift(1));
      end
      if rem(ranshift(2),2)==0
        nowposY = posY(i)+vec(ranshift(2));
      elseif rem(ranshift(2),2)~=0
        nowposY = posY(i)-vec(ranshift(2));
      end
      rectangle('Position', [nowposX nowposY 35 35], 'FaceColor',[colors(:,i)]);
    else
      rectangle('Position', [posX(i) posY(i) 35 35], 'FaceColor',[colors(:,i)]);
    end
    %imagesc([posX(i); posY(i); vel(i)], [min(vel) max(vel)])
    hold on

    %else %
    %imagesc(limitedmatrix(:,:,i)', [1 2]) %
    %hold on %
    %end %

    axis xy
    str1 = {'Frame' i };
    t = text(2,2,str1, 'r');
    t.FontSize = 12;
    t.Color = 'red';
    M(i) = getframe;
    alpha(.5)
    %if length(delay)==1
    %    fr = delay*100;
    %    M(f:(f+fr)) = getframe;
        pause(delay)
    %    f = f+fr;
    %end
    k
end

%video = VideoWriter('822remdecode.avi')
%video.FrameRate = 5;
%open(video);

%writeVideo(video, M);
