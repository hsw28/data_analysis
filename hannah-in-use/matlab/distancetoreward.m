function f = distancetoreward(XYlocations)
%returns results in CMs

if size(XYlocations,2) <  size(XYlocations,1)
   XYlocations = XYlocations';
end

%second dimension is bigger


%now find distance to reward sites
%center arm 460 pixels
%each arm 240 pixels


%if forced arm, distance to choice point, middle plus choice arm
dist = [];
for k = 1:length(XYlocations)
  x = XYlocations(1,k);
  y = XYlocations(2,k);
  if x<430
    toforced = pdist([x, y; 420, 360]);
    dist(end+1) = toforced+460+240;
%if middle arm, distance to choice point plus length of choice arm
  elseif x>430 & x<830
    tochoice = pdist([x, y; 830, 380]);
    dist(end+1) = tochoice+240;
%if on choice arms, just figure out which site is closer and get distance to there
%left choice arm
  elseif x>700 & y>375
    toreward = pdist([x, y; 838, 630]);
    dist(end+1) = toreward;
%right choice arm
  elseif x>700 & y<375
    toreward = pdist([x, y; 886, 120]);
    dist(end+1) = toreward;
  end
end

%convert to cm
f = (dist./3.5)';
