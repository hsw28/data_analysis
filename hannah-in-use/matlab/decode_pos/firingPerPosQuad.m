function f = firingPerPosQuad(posData, clusters, tdecode)
%returns firing per position. dim is number of centimeters for binning

velthreshold = 12;
spikenames = (fieldnames(clusters));
spikenum = length(spikenames);




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

%defiding position
xlimmin = [320 320 320 320 320 460 750 780 835 780 780];
xlimmax = [505 505 460 505 505 835 950 950 950 950 950];
ylimmin = [548 410 315 127 000 300 556 415 334 187 000];
ylimmax = [700 548 410 315 127 440 700 556 415 334 187];


  timecells = zeros(length(xlimmin), 1); %used to be time
  events = zeros(length(xlimmin), 1);
  tstep = 1/30;


%only uses data that is >15cm/s -- first smooths for length of bin
vel = velocity(posData);
vel(1,:) = smoothdata(vel(1,:), 'gaussian', tdecode*15); %originally had this at 30, trying with 15 now
fastvel = find(vel(1,:) > velthreshold);
posDataFast = posData(fastvel, :);
fastX = (posDataFast(:,2));
fastY = (posDataFast(:,3));





for k=1:length(xlimmin)
inX = find(fastX > xlimmin(k) & fastX<=xlimmax(k));
inY = find(fastY > ylimmin(k) & fastY<=ylimmax(k));
inboth = intersect(inX, inY);
timecells(k) = length(inboth);
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
      for k=1:length(xlimmin)
      inX = find(ls(:,2)> xlimmin(k) & ls(:,2)<=xlimmax(k));
      inY = find(ls(:,3) > ylimmin(k) & ls(:,3)<=ylimmax(k));
      inboth = intersect(inX, inY);
      events(k) = length(inboth);
      end


      rate = events./(timecells*tstep)+eps; %time*tstep is occupancy %want this for all cells
      myStruct.(spikename) = rate;
    else
      rate = zeros(xbins, ybins);
      warning('the cell doesnt have enough points')
      spikename
    end
end

f = myStruct;
