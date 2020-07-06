function [f bounds] = decodeshitPos_linear(time, pos, clusters, tdecode, dim, varargin)
%put anything in varargin for REM

%decodes position and outputs decoded x, y, confidence(in percents), and time.
%if you want to filter spiking for veloctity you put velocity in varargin
%dim is bin sie in cm
%tdecode is decoding in seconds

purepos = pos;
velthreshold = 12;

tic

posData = pos;
posData = fixpos(posData);


if length(varargin)<1
[cc indexmin] = min(abs(posData(1,1)-time));
[cc indexmax] = min(abs(posData(end,1)-time));
timevector = time(indexmin:indexmax);
time = timevector;
else
timevector = time;
end



vel = velocity(posData);
vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
goodvel = find(vel>=velthreshold);



x = pos(:,2);
y = pos(:,3);
bound = boundary(x,y);
xbound = x(bound);
ybound = y(bound); %these are the outline coordinates

%FOR LEFT COLUMN
lleftbound = min(xbound); %leftbound
%rightbound
ytemp = find(ybound>410 | ybound<310);
xtemp = find(xbound<550);
xtemp = intersect(xtemp, ytemp);
lrightbound = max(xbound(xtemp)); %rightbound
%topbound
xtemp = find(xbound<520);
ltopbound = max(ybound(xtemp)); %topbound
%bottombound
xtemp = find(xbound<520);
lbottombound = min(ybound(xtemp)); %topbound
%bounds on left arm: lleftbound, lrightbound, ltopbound, lbottombound

%FOR RIGHT COLUMN
rrightbound = max(xbound); %rightbound
%leftbound
ytemp = find(ybound>420 | ybound<320);
xtemp = find(xbound>800);
xtemp = intersect(xtemp, ytemp);
rleftbound = min(xbound(xtemp)); %rightbound
%topbound
xtemp = find(xbound>740);
rtopbound = max(ybound(xtemp)); %topbound
%bottombound
xtemp = find(xbound>740);
rbottombound = min(ybound(xtemp)); %topbound
%bounds on left arm: rleftbound, rrightbound, rtopbound, rbottombound

%FOR MIDDLE
%is between lrightbound and rleftbound
xtemp = find(xbound>lrightbound & xbound<rrightbound);
mtopbound = max(ybound(xtemp));
mbottombound = min(ybound(xtemp));
mleftbound = lrightbound;
mrightbound = rleftbound;
%bounds on bottom: mleftbound, mrightbound, mtopbound, mbottombound

%BIN
psize = 3.5 * dim;

%want to make a vector of all the increments
%LEFT ARM
bottomvec = [];
topvec = [];
for lb = 0:floor((ltopbound-lbottombound)./psize)
  bottomvec(end+1) = lbottombound+(lb*psize);
  topvec(end+1) = lbottombound+((lb+1)*psize);
end
leftvectemp1 = ones((length(bottomvec)),1)*lleftbound;
leftvectemp2 = ones((length(bottomvec)),1)*lrightbound;
leftvect = [leftvectemp1, leftvectemp2, bottomvec', topvec']; %LEFT ARM

%right ARM
bottomvec = [];
topvec = [];
for rb = 0:floor((rtopbound-rbottombound)./psize)
  bottomvec(end+1) = rbottombound+(rb*psize);
  topvec(end+1) = rbottombound+((rb+1)*psize);
end
rightvectemp1 = ones((length(bottomvec)),1)*rleftbound;
rightvectemp2 = ones((length(bottomvec)),1)*rrightbound;
rightvect = [rightvectemp1, rightvectemp2, bottomvec', topvec']; %RIGHT ARM
%MIDDLE ARM
leftvec = [];
rightvec = [];
for rb = 0:floor((mrightbound-mleftbound)./psize)
  leftvec(end+1) = mleftbound+(rb*psize);
  rightvec(end+1) = mleftbound+((rb+1)*psize);
end
topvectemp1 = ones((length(leftvec)),1)*mtopbound;
bottomvectemp2 = ones((length(leftvec)),1)*mbottombound;
midvect = [leftvec', rightvec', bottomvectemp2, topvectemp1]; %MIDDLE ARM

allvec = [leftvect; rightvect; midvect]; %dimesions are [n, 4]

xvals = posData(:,2);
yvals = posData(:,3);


tdecodesec = tdecode;
t = 2000*tdecode;


%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);

% for each cluster,find the firing rate at esch velocity range
%firingPerPos_linear(posData, clusters, tdecode, pos_samp_per_sec, bounds, varargin)
fxmatrix = firingPerPos_linear(posData, clusters, tdecodesec, 30, allvec, velthreshold);
names = (fieldnames(fxmatrix));
for k=1:length(names)
  curname = char(names(k));
  %fxmatrix.(curname) = chartinterp(fxmatrix.(curname));
  fxmatrix.(curname) = ndnanfilter(fxmatrix.(curname), 'gausswin', [dim*2/dim, dim*2/dim], 2, {}, {'replicate'}, 1);
end


maxprob = [];
spikenum = 1;
times = [];
percents = [];
numcel = [];
maxx = [];
maxy = [];
same = 0;

occ = zeros(length(allvec),1);
testing = 0;
for xy = (1:size(allvec,1)) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES

    occx = find(xvals>=allvec(xy,1) & xvals<allvec(xy,2));
    occy = find(yvals>=allvec(xy,3) & yvals<allvec(xy,4));
    if length(intersect(occx, occy)) ==0
      occ(xy) = 0;
    else
      occ(xy) = 1;
    end

end


occ;


n =0;
nivector = zeros((numclust),1);
tm = 1;
while tm < (length(timevector)-t)
  goodvel = find(vel(2,:)>=timevector(tm) & vel(2,:)<timevector(tm+t));

%  if nanmean((vel(1,goodvel)))>velthreshold & nanmedian((vel(1,goodvel)))>velthreshold
  if length(find(vel(1,goodvel)>velthreshold)) >= length(goodvel)*.75
   %find spikes in each cluster for time
   nivector = zeros((numclust),1);
   for c=1:numclust   %permute through cluster
     name = char(clustname(c));
     %find number of cells that fire during each period
     nivector(c) = length(find(clusters.(name)>=timevector(tm) & clusters.(name)<timevector(tm+t)));
   end

      %for the cluster, permute through the different positions
    endprob = zeros(length(allvec),1);

      for xy = (1:size(allvec,1)) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
          productme =0;
          expme = 0;
          c = 1;

          if occ(xy) == 0 %means never went there, dont consider
            endprob(xy) = NaN;
          %  break
          end

          for c=1:numclust  %permute through cluster
              ni = nivector(c);
              name = char(clustname(c));
              fx = fxmatrix.(name);


              fx = (fx(xy));
              productme = productme + (ni)*log(fx);  %IN
              expme = (expme) + (fx);
               % goes to next cell, same location

          end
          numcel(end+1) = (ni);
          % now have all cells at that location
          tmm = tdecodesec;

        endprob(xy) = (productme) + (-tmm.*expme); %IN

        end
        [maxval] = find(endprob == max(endprob(:)));

        mp = max(endprob(:))-12;

      endprob = exp(endprob-mp);


         %finds indices
        conv = 1./sum(endprob(~isnan(endprob)), 'all');
        endprob = endprob.*conv; %matrix of percents
        %percents = vertcat(percents, endprob);

        percents(end+1) = max(endprob(:)); %finds confidence
        if length(maxval) > 1 %if probs are the sample, randomly pick one and print warning
            same = same+1;
            maxval = datasample(maxval, 1);
            maxval = datasample(maxval, 1);

        end

            if length(maxval) <1
              maxx(end+1) = NaN;
              maxy(end+1) = NaN;
            else
              maxx(end+1) = mean([allvec(maxval,1), allvec(maxval,2)]); %translates to x and y coordinates
              maxy(end+1) = mean([allvec(maxval,3), allvec(maxval,4)]);
            end


    else
      %means vel is too low
      maxx(end+1) = NaN;
      maxy(end+1) = NaN;
      percents(end+1) = NaN;

    end

        times(end+1) = timevector(tm);

    %if want overlap
    if tdecodesec>=.5
      tm = tm+(t/2);
    else
      tm = tm+t;
    end

    n = n+1;
    if rem(n,5000)==0
      n
    end
end

warning('your probabilities were the same')
same = same
%maxx = maxx+psize/2;
%maxy = maxy+psize/2;
values = [maxx; maxy; percents; times];
toc;
f = values;

%{
error = decodederror(f, purepos, tdecode);
error_av = nanmean(error(1,:))
error_med = nanmedian(error(1,:))

error = decodederror_linear(f, purepos, tdecode, allvec);
error_lin_av = nanmean(error(1,:))
error_lin_med = nanmedian(error(1,:))
%}

bounds = allvec;
