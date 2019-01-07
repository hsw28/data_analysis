function f = velrankquad(posData, vel, confidencethreshold, decodet)
%posData should be in the format (time,x,y) or (x,y,prob,time)
%vel should be in (vel, time, varargin)
%MAKE SURE CONFIDENCE THRESHOLD IS LIKE .3 AND NOT 30%

xlimmin = [320 320 320 320 320 440 750 780 828 780 780];
xlimmax = [505 450 440 505 505 828 950 950 950 950 950];
ylimmin = [545 422 320 170 000 300 575 420 339 182 000];
ylimmax = [700 545 422 320 170 440 700 575 420 339 182];

%determine if position file or decoded file
if size(posData,1)>size(posData,2) %actual position
  mintimepos = min(posData(:,1));
  maxtimepos = max(posData(:,1));
  timepos = posData(:,1);
  X = (posData(:,2));
  Y = (posData(:,3));
  quad = zeros(length(posData), 1);
  for k=1:length(xlimmin)
    inX = find(X > xlimmin(k) & X<=xlimmax(k));
    inY = find(Y > ylimmin(k) & Y<=ylimmax(k));
    inboth = intersect(inX, inY);
    quad(inboth) = k;
  end

else %means binned and decoded
  highprobpos = find(posData(2,:)>confidencethreshold);
  posData = posData(:,highprobpos);
  mintimepos = min(posData(3,:));
  maxtimepos = max(posData(3,:));
  timepos = posData(3,:);
  quad = (posData(1,:));

%havent done SWR for quads yet%%
%elseif size(posData,1)==5 %means SWR decoded
  %highprobpos = find(posData(3,:)>confidencethreshold);
  %posData = posData(:,highprobpos);
  %mintimepos = min(posData(4,:));
  %maxtimepos = max(posData(5,:));
  %X = (posData(1,:))';
  %Y = (posData(2,:))';
  %timepos = posData(4,:)';

end

%set velocities
%%%%%%%%%%%%%%%FOR TESTING: USE ONLY CONFIDENCES ABOVE 30%
if size(vel,1)==4
  highprobvel = find(vel(4,:)>confidencethreshold);
  vel = vel(:,highprobvel);
  mintimevel = min(vel(2,:));
  maxtimevel = max(vel(2,:));
  timevel = vel(2,:);
  vel = vel(1,:);

elseif size(vel,1)==5
  highprobvel = find(vel(3,:)>confidencethreshold);
  vel = vel(:,highprobvel);

  mintimevel = min(vel(4,:));
  maxtimevel = max(vel(5,:));
  timevel = (vel(4,:));
  vel = vel(1,:);

else
  mintimevel = min(vel(2,:));
  maxtimevel = max(vel(2,:));
  timevel = vel(2,:);
  vel = vel(1,:);

end
%%ENDDDDD


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
  quad = quad(indexmin:end);
end

if maxtimepos >maxtimevel
  %cut pos end
  [c indexmin] = (min(abs(timepos-maxtimevel)));
  timepos = timepos(1:indexmin);
  quad = quad(1:indexmin);
elseif maxtimepos < maxtimevel
  %cut vel end
  [c indexmin] = (min(abs(timevel-maxtimepos)));
  timevel = timevel(1:indexmin);
  vel = vel(1:indexmin);
end


posData = [timepos, quad];

%putting in approx values here for now, just want them to always be same i think

timeMAZEinc = timevel(1):.0333:timevel(end);
vel = [vel; timevel];
%vel = assignvel(timeMAZEinc, vel);
%f.velinterp = [vel; timeMAZEinc];
if decodet > 0
  vel = smoothdata(vel(1,:), 'gaussian', decodet*15); %originally had this at 30, trying with 15 now
%else
  %vel = smoothdata(vel(1,:), 'gaussian', 0);
end
%vel = [vel; timeMAZEinc];
f.veltester = vel;
quadvel = assignvelOLD(timepos, vel);

f.vel = [quad, quadvel', timepos];

linearmean = zeros(max(quad),1);
linearnum = zeros(max(quad),1);
quadpos = zeros(max(quad),1);


for n=1:max(quad)
  currentvel = 0;
  goodk = 0;
  wantquad = find(quad==n);
  for k = 1:length(wantquad)
     ind = wantquad(k);
     if quadvel(ind)>5
        currentvel = currentvel+quadvel(ind);
        goodk = goodk+1;
    end
  end

        quadpos(n) = n;
        linearnum(n) = goodk;
        velmean = (currentvel)./goodk;
        linearmean(n) = velmean;
end

f.test = [linearmean, quadpos]


if length(quad)>1000
  low = find(linearnum<=ceil(length(quad)*.001));
  linearmean(low) = NaN;
else
  low = find(linearnum<2);
  linearmean(low) = NaN;
end


  [avs,idx] = sort(linearmean);
  sorted = [[1:1:length(idx)]; idx'; avs'; linearnum(idx)']';

  sortnan = find(isnan(sorted(:,3)));
  sorted(sortnan,1) = NaN;

  %sorted = sortrows(sorted, 2);
  %sorted(:,1) = sorted(:,1)./max(sorted(:,1)); %????

  f.averages =  [quadpos, linearmean]
  f.order = sorted;
