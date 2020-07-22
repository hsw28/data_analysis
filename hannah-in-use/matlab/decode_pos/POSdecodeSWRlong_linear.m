function f = POSdecodeSWRlong_linear(SWRstartend, pos, clusters, dim, tdecode, varargin)
%decodes ripples in 20ms chunks
%input the output for findripMUA.m
%if inputting in only peak time, use varargin to specify seconds around peak time

%%%%%%FILL IN

%if size(SWRstartend,1)>size(SWRstartend,2)
%  SWRstartend = SWRstartend';
%end



size(SWRstartend,1);

if size(SWRstartend,1)==3 %means you're inputting start and end times
  SWRstart = SWRstartend(1,:);
  SWRend = SWRstartend(3,:);
elseif size(SWRstartend,1)==1 %means you're just putting in mid time
  timeshift = cell2mat(varargin);
  SWRstart = SWRstartend-timeshift;
  SWRend = SWRstartend+timeshift;
end

%posstart = pos(1,1);
%posend = pos(end,1);

%[c startindex] = min(abs(SWRstart-posstart));
%[c endindex] = min(abs(SWRend-(posend+40*60))); %40 min after run

%SWRstart = SWRstart(startindex:endindex);
%SWRend = SWRend(startindex:endindex);




SWRstart;
SWRend;

posData = pos;
posData = fixpos(posData);

%timevector = time;


%t = tdecode;
%t = 2000*t;
%tm = 1;

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);

velthreshold = 12;
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

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);

% for each cluster,find the firing rate at esch velocity range
%firingPerPos_linear(posData, clusters, tdecode, pos_samp_per_sec, bounds, varargin)

%decoding at 1 sec
fxmatrix = firingPerPos_linear(posData, clusters, 1, 30, allvec, velthreshold);

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


n =0;
nivector = zeros((numclust),1);


all_decoded = NaN(5,10, length(SWRstart));
for r=1:(length(SWRstart))

  currend = SWRstart(r);
  newend = currend;
  maxx = [];
  maxy= [];
  percents= [];
  currstart_vec = [];
  currend_vec = [];

  while newend < SWRend(r)
    currstart = currend;
      currend = newend;


  %dont need to make sure the animal is moving bc ripple

  %while tm < (floor(SWRend(r) - SWRstart(r))./tdecode)

   %find spikes in each cluster for time
   nivector = zeros((numclust),1);
   for c=1:numclust   %permute through cluster
     name = char(clustname(c));
     nivector(c) = length(find(clusters.(name)>=currstart & clusters.(name)<currend));
   end

      %for the cluster, permute through the different conditions
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
        tmm = currend-currstart;


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

      currstart_vec(end+1) = currstart;
      currend_vec(end+1) = currend;

          if length(maxval) <1
            maxx(end+1) = NaN;
            maxy(end+1) = NaN;
          else
            maxx(end+1) = mean([allvec(maxval,1), allvec(maxval,2)]); %translates to x and y coordinates
            maxy(end+1) = mean([allvec(maxval,3), allvec(maxval,4)]);
          end

        if (currend+.02) <= SWRend(r)
          newend = currend+.02;
        elseif (currend+.15) <= SWRend(r)
          newend = currend+.15
        else
          newend = currend+.02;
        end

      end

      maxx = maxx+psize/2;
      maxy = maxy+psize/2;
      values = [maxx; maxy; percents; currstart_vec; currend_vec];
      all_decoded(:,1:length(values),r)= values;

end

%warning('your probabilities were the same')
%same = same
%maxx = maxx+psize/2;
%maxy = maxy+psize/2;
%values = [maxx; maxy; percents; SWRstart; SWRend];

f = all_decoded;
