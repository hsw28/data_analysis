function f = POSdecodeSWRsegments_linear(SWRstartend, pos, clusters, dim, tdecode, varargin)
%decodes position in each SWR seperately. input the output for findripMUA.m
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


allvec = findlinearbounds(posData);

xvals = posData(:,2);
yvals = posData(:,3);

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);

% for each cluster,find the firing rate at esch pos

%decoding at 1 sec
fxmatrix = firingPerPos_linear(posData, clusters, 1, 30, allvec, velthreshold);


names = (fieldnames(fxmatrix));
for k=1:length(names)
  curname = char(names(k));
  %fxmatrix.(curname) = chartinterp(fxmatrix.(curname));
  fxmatrix.(curname) = ndnanfilter(fxmatrix.(curname), 'gausswin', [2,2], 2, {}, {'replicate'}, 1);
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


for r=1:(length(SWRstart))
  %dont need to make sure the animal is moving bc ripple

  %while tm < (floor(SWRend(r) - SWRstart(r))./tdecode)

   %find spikes in each cluster for time
   nivector = zeros((numclust),1);
   for c=1:numclust   %permute through cluster
     name = char(clustname(c));
     nivector(c) = length(find(clusters.(name)>=SWRstart(r) & clusters.(name)<SWRend(r)));
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
        tmm = SWRend(r)-SWRstart(r);


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

            %r = r+1

end

warning('your probabilities were the same')
same = same

values = [maxx; maxy; percents; SWRstart; SWRend];

f = values';
