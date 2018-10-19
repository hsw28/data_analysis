function f = firingPerPos(posData, clusters, dim, tdecode)
%returns firing per position. dim is number of centimeters for binning

velthreshold = 12;
spikenames = (fieldnames(clusters));
spikenum = length(spikenames);


psize = 3.5 * dim; %some REAL ratio of pixels to cm


%only find occupancy map if one hasn't been provided

mintime = min(posData(:,1));
maxtime = max(posData(:,1));
oldtime = posData(:,1);
X = (posData(:,2));
Y = (posData(:,3));

timeMAZEinc = mintime:.0333:maxtime;
newX = interp1(oldtime, X, timeMAZEinc, 'pchip');
newY = interp1(oldtime, Y, timeMAZEinc, 'pchip');
posData = [timeMAZEinc; newX; newY]';

xmin = min(posData(:,2));
ymin = min(posData(:,3));
xmax = max(posData(:,2));
ymax = max(posData(:,3));

xbins = ceil((xmax-xmin)/psize); %number of x
ybins = ceil((ymax-ymin)/psize); %number of y
  timecells = zeros(xbins, ybins); %used to be time
  events = zeros(xbins,ybins);
  xstep = xmax/xbins;
  ystep = ymax/ybins;
  tstep = 1/30;


  xinc = xmin +(0:xbins)*psize; %makes a vectors of all the x values at each increment
  yinc = ymin +(0:ybins)*psize; %makes a vector of all the y values at each increment

%only uses data that is >15cm/s -- first smooths for length of bin
vel = velocity(posData);
vel(1,:) = smoothdata(vel(1,:), 'gaussian', tdecode*15); %originally had this at 30, trying with 15 now
fastvel = find(vel(1,:) > velthreshold);
posDataFast = posData(fastvel, :);



%defiding position
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
        %	A1 = posData(:,2)>((i-1)*xstep) & posData(:,2)<=(i*xstep); %finds all rows that are in the current x axis bin
        %	A2 = posData(:,3)>((j-1)*ystep) & posData(:,3)<=(j*ystep); %finds all rows that are in the current y axis bin
        %  A = [A1 A2]; %merge results
        %  B = sum(A,2); %find the rows that satisfy both previous conditions
        %  C = B > 1; % this is the correct row
        %%  timecells(ybins+1-j,i) = sum(C); %amount of time in each bin
      end
    end



for k = 1:spikenum
    spikename = char(spikenames(k));
    unit = clusters.(spikename);

    [m firstspike] = min(abs(unit-mintime));
    [m lastspike] = min(abs(unit-maxtime));
    unit = unit(firstspike:lastspike);

    assvel = assignvelOLD(unit, vel);
    fastspikeindex = find(assvel > velthreshold);
    fastspike = unit(fastspikeindex);
    ls = placeevent(fastspike, posData); %outputs [event; xposvector; yposvector];
    ls = ls';
    if length(fastspikeindex)>0
    %WILL NEED TO DO THIS FOR ALL CELLS
    for x = (1:xbins)
        for y = (1:ybins)
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

            %A1 = ls(:,2)>((i-1)*xstep) & ls(:,2)<=(i*xstep); %finds all rows that are in the current x axis bin
            %A2 = ls(:,3)>((j-1)*ystep) & ls(:,3)<=(j*ystep); %finds all rows that are in the current y axis bin
            %A = [A1 A2]; %merge results
            %B = sum(A,2); %find the rows that satisfy both previous conditions
            %C = B > 1;
            %set the matrix cell for that bin to the number of rows that satisfy both
            %events(ybins+1-j,i) = sum(C); %number of spikes in each bin
        end
    end

    rate = events./(timecells*tstep); %time*tstep is occupancy %want this for all cells
    rate = rate(1:xbins, 1:ybins);
    myStruct.(spikename) = rate;
    else
    rate = zeros(xbins, ybins);
    warning('the cell doesnt have enough points')
    spikename
    end
end

fprintf('firing per complete')
f = myStruct;
