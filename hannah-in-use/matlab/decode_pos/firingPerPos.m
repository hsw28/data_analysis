function f = firingPerPos(posData, clusters, dim, tdecode, pos_samp_per_sec, varargin)
%returns firing per position. dim is number of centimeters for binning

if length(varargin)>1
  velthreshold = cell2mat(varargin)
else
velthreshold = 12;
end

spikenames = (fieldnames(clusters));
spikenum = length(spikenames);


psize = 3.5 * dim; %some REAL ratio of pixels to cm



%only find occupancy map if one hasn't been provided

mintime = min(posData(:,1));
maxtime = max(posData(:,1));

pos_samp_per_sec = length(posData(:,1))./(maxtime-mintime);  %29
%tms = [posData(1,1):.0333:posData(end,1)];
%posData = assignpos(tms, posData);

oldtime = posData(:,1);
X = (posData(:,2));
Y = (posData(:,3));


xmin = min(posData(:,2));
ymin = min(posData(:,3));
xmax = max(posData(:,2));
ymax = max(posData(:,3));



xbins = ceil((xmax-xmin)/psize); %number of x
ybins = ceil((ymax-ymin)/psize); %number of y
if ybins==0
  ybins = 1;
end
  timecells = zeros(xbins, ybins); %used to be time
  events = zeros(xbins,ybins);
  xstep = xmax/xbins;
  ystep = ymax/ybins;
  tstep = 1/pos_samp_per_sec;


  xinc = xmin +(0:xbins)*psize; %makes a vectors of all the x values at each increment
  yinc = ymin +(0:ybins)*psize; %makes a vector of all the y values at each increment

%only uses data that is >15cm/s -- first smooths for length of bin
vel = velocity(posData);

posData = fixpos(posData);

vel(1,:) = smoothdata(vel(1,:), 'gaussian', pos_samp_per_sec); %originally had this at 30, trying with 15 now

fastvel = find(vel(1,:) > velthreshold);

%posData = fixpos(posData);
size(posData)
posDataFast = posData(fastvel, :);




%defiding position
%if length(varargin)>1
%  timecells = cell2mat(varargin)
if 0==1
else
  for x = (1:xbins) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
    for y = (1:ybins)

        if x<xbins & y<ybins
          inX = find(posDataFast(:,2)>=xinc(x) & posDataFast(:,2)<xinc(x+1));
          inY = find(posDataFast(:,3)>=yinc(y) & posDataFast(:,3)<yinc(y+1));
        elseif x==xbins & y<ybins
          inX = find(posDataFast(:,2)>=xinc(x));
          inY = find(posDataFast(:,3)>=yinc(y) & posDataFast(:,3)<yinc(y+1));
        elseif x<xbins & y==ybins
          inX = find(posDataFast(:,2)>=xinc(x) & posDataFast(:,2)<xinc(x+1));
          inY = find(posDataFast(:,3)>=yinc(y));
        elseif x==xbins & y==ybins
          inX = find(posDataFast(:,2)>=xinc(x));
          inY = find(posDataFast(:,3)>=yinc(y));
        end

        inboth = intersect(inX, inY);
        timecells(x, y) = length(inboth);
      end
    end
end





for k = 1:spikenum
    events(:)=NaN;
    spikename = char(spikenames(k))
    unit = clusters.(spikename);
    [m firstspike] = min(abs(unit-mintime));
    [m lastspike] = min(abs(unit-maxtime));
    unit = unit(firstspike:lastspike);

    assvel = assignvelOLD(unit, vel);
    fastspikeindex = find(assvel > velthreshold);
    fastspike = unit(fastspikeindex);
    size(fastspike);
    ls = placeevent(fastspike, posData); %outputs [event; xposvector; yposvector];
    ls = ls';

    minX = min(ls(:,2));
    maxX = max(ls(:,2));
    minY = min(ls(:,3));
    maxY = max(ls(:,3));
    [minValue, minX] = min(abs(minX-xinc));
    minX = minX-1;
    [minValue, maxX] = min(abs(maxX-xinc));
    maxX = maxX+1;
    [minValue, minY] = min(abs(minY-yinc));
    minY = minY-1;
    [minValue, maxY] = min(abs(maxY-yinc));
    maxY = maxY+1;

    if minX<1
      minX = 1;
    end
    if maxX>(xbins)
      maxX = (xbins);
    end
    if minY<1
      minY = 1;
    end
    if maxY>(ybins)
      maxY = (ybins);
    end

    if length(fastspikeindex)>0
    %WILL NEED TO DO THIS FOR ALL CELLS
    for x = minX:maxX
        for y = minY:maxY

          if x<xbins & y<ybins
            inX = find(ls(:,2)>=xinc(x) & ls(:,2)<xinc(x+1));
            inY = find(ls(:,3)>=yinc(y) & ls(:,3)<yinc(y+1));
          elseif x==xbins & y<ybins
            inX = find(ls(:,2)>=xinc(x));
            inY = find(ls(:,3)>=yinc(y) & ls(:,3)<yinc(y+1));
          elseif x<xbins & y==ybins
            inX = find(ls(:,2)>=xinc(x) & ls(:,2)<xinc(x+1));
            inY = find(ls(:,3)>=yinc(y));
          elseif x==xbins & y==ybins
            inX = find(ls(:,2)>=xinc(x));
            inY = find(ls(:,3)>=yinc(y));
          end

          inboth = intersect(inX, inY);
          events(x,y) = length(inboth);
          if events(x,y)>0 & timecells(x,y)==0
            timecells(x,y) = 1;
          end
        end
    end


    rate = events./(timecells*tstep)+eps; %time*tstep is occupancy %want this for all cells
    myStruct.(spikename) = rate;
    else
    rate = zeros(xbins, ybins);
    warning('the cell doesnt have enough points')
    spikename
    end


end

fprintf('firing per complete')
f = myStruct;

%[row,col] = find(rate==Inf)
%for k=1:length(row)
%  [events(row(k),col(k)), timecells(row(k),col(k))];
%end
