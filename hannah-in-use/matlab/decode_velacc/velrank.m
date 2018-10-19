function f = velrank(posData, vel, dim)
%posData should be in the format (time,x,y) or (x,y,prob,time)
%vel should be in (vel, time, varargin)


psize = 3.5 * dim; %some REAL ratio of pixels to cm

%determine which position is being used
if size(posData,2) == 3 %this means non decoded
  mintimepos = min(posData(:,1));
  maxtimepos = max(posData(:,1));
  timepos = posData(:,1);
  X = (posData(:,2));
  Y = (posData(:,3));
%  if size(vel,1) >2 %means vel was decoded-- we will interpolate up position so sampling is equal
%    timeMAZEinc = mintime:.0333:maxtime;
%    X = interp1(timepos, X, timeMAZEinc, 'pchip');
%    Y = interp1(timepos, Y, timeMAZEinc, 'pchip');
%    timepos = timeMAZEinc;
%  end
elseif size(posData,1)==4
  mintimepos = min(posData(4,:));
  maxtimepos = max(posData(4,:));
  oldtimepos = posData(4,:);
  X = (posData(1,:));
  Y = (posData(2,:));
end

%set velocities
mintimevel = min(vel(2,:));
maxtimevel = max(vel(2,:));
timevel = vel(2,:);
vel = vel(1,:);

%cut so same
if mintimepos>mintimevel
  %cut vel start
  [c indexmin] = (min(abs(timevel-mintimepos)));
  timevel = timevel(indexmin:end);
  vel = vel(indexmin:end);
elseif mintimepos<mintimevel
  %cut pos start
  [c indexmin] = (min(abs(timepos-mintimevel)));
  timepos = timepos(indexmin:end);
  X = X(indexmin:end);
  Y = Y(indexmin:end);
elseif maxtimepos >maxtimevel
  %cut pos end
  [c indexmin] = (min(abs(timepos-maxtimevel)));
  timepos = timepos(1:indexmin);
  X = X(1:indexmin);
  Y = Y(1:indexmin);
elseif maxtimepos < maxtimevel
  %cut vel end
  [c indexmin] = (min(abs(timevel-maxtimepos)));
  timevel = timevel(1:indexmin);
  vel = vel(1:indexmin);
end

posData = [timepos, X, Y];

%putting in approx values here for now, just want them to always be same i think
xmin = 360;
ymin = 70;
xmax = 920;
ymax = 675;


xbins = ceil((xmax-xmin)/psize); %number of x
ybins = ceil((ymax-ymin)/psize); %number of y
xstep = xmax/xbins;
ystep = ymax/ybins;
xinc = xmin +(0:xbins)*psize; %makes a vectors of all the x values at each increment
yinc = ymin +(0:ybins)*psize; %makes a vector of all the y values at each increment

timesforvel = placeevent(timevel, posData); %vectortxy = [time'; xposvector; yposvector];
timesforvel = timesforvel';

averagecells = zeros(xbins, ybins);
numincells = zeros(xbins,ybins);
%defiding position
  for x = (1:xbins) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
    for y = (1:ybins)
        if x<xbins & y<ybins
          inX = find(timesforvel(:,2)>=xinc(x) & timesforvel(:,2)<xinc(x+1));
          inY = find(timesforvel(:,3)>=yinc(y) & timesforvel(:,3)<yinc(y+1));
        elseif x==xbins & y<ybins
          inX = find(timesforvel(:,2)>=xinc(x));
          inY = find(timesforvel(:,3)>=yinc(y) & timesforvel(:,3)<yinc(y+1));
        elseif x<xbins & y==ybins
          inX = find(timesforvel(:,2)>=xinc(x) & timesforvel(:,2)<xinc(x+1));
          inY = find(timesforvel(:,3)>=yinc(y));
        elseif x==xbins & y==ybins
          inX = find(timesforvel(:,2)>=xinc(x));
          inY = find(timesforvel(:,3)>=yinc(y));
        end
        inboth = intersect(inX, inY); %inboth is the velocity index for cells in that bin
        if length(inboth)>0
          velinboth = vel(inboth);
          avinboth = mean(velinboth);
          averagecells(x, y) = avinboth;
          numincells(x,y) = length(inboth);
        else
          averagecells(x, y) = NaN;
          numincells(x,y) = NaN;
        end


      end
    end



  linearmean = reshape(averagecells,[1 xbins*ybins]);
  linearnum = reshape(numincells,[1 xbins*ybins]);
  [avs,idx] = sort(linearmean);
  sorted = [[1:1:length(idx)];idx; avs; linearnum(idx)]';
  sorted = sortrows(sorted, 2);


  f.averages =  averagecells;
  f.samples =   numincells;
  f.order = sorted;
