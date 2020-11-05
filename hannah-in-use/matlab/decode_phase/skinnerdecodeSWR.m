function [matrices radon_results zz]  = skinnerdecodeSWR(SWRstartend, time, cueOn, clusters, tdecode, tsegment, varargin)

%tdecode is bins in seconds you want the results decoded in (so like .015 for ripples).
%tsegment is segments you want skinner rates calculated in (for example 8sec for all cue time unchunked)
%decodes ripples in 20ms chunks
%input the output for findripMUA.m
%if inputting in only peak time, use varargin to specify seconds around peak time

%%%%%%FILL IN

%if size(SWRstartend,1)>size(SWRstartend,2)
%  SWRstartend = SWRstartend';
%end

[c startindex] = min(abs(time-cueOn(1)));
[c endindex] = min(abs(time-cueOn(end)));
timevector = time(startindex:(endindex+(17*2000)));

if tdecode>.1
  error('tdecode should be in fractions of seconds. for ex .02 for 20ms')
end



%if size(SWRstartend,1)==3 %means you're inputting start and end times
  SWRstart = SWRstartend(1,:);
  SWRend = SWRstartend(3,:);
%elseif size(SWRstartend,1)==1 %means you're just putting in mid time
%  timeshift = cell2mat(varargin);
%  SWRstart = SWRstartend-timeshift;
%  SWRend = SWRstartend+timeshift;
%end




%find number of clusters
clustname = (fieldnames(clusters));

numclust = length(clustname);


numofbins = ((8/tsegment)*2);

% for each cluster,find the firing rate at esch velocity range
%firingPerPos_linear(posData, clusters, tdecode, pos_samp_per_sec, bounds, varargin)

%decoding at 1 sec
j = 1;
fxmatrix = zeros(numclust, numofbins);
while j <= numclust
    name = char(clustname(j));
    fxmatrix(j,:) = firingPerPhaseCueRew(timevector, cueOn, clusters.(name), tsegment);
    j = j+1;
end
fxmatrix

maxprob = [];
spikenum = 1;
times = [];
percents = [];
numcel = [];


percents = [];

t = tdecode;
t = 2000*t;
tm = 1;
debug = 0;



n =0;
nivector = zeros((numclust),1);


all_decoded = NaN(3,10, length(SWRstart));
for r=1:(length(SWRstart))

endproball = [];

  currend = SWRstart(r);
  newend = currend;
  maxx = [];
  maxy= [];
  percents= [];
  currstart_vec = [];
  currend_vec = [];



  while newend <= SWRend(r)
    currstart = currend;
      currend = newend;


   %find spikes in each cluster for time
   nivector = zeros((numclust),1);

   for c=1:numclust   %permute through cluster
     name = char(clustname(c));
     nivector(c) = length(find(clusters.(name)>=currstart & clusters.(name)<currend));
   end

nivector;
      %for the cluster, permute through the different conditions
    endprob = zeros((numofbins),1);



    for k = (1:numofbins) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
        productme =0;
        expme = 0;
        c = 1;

        for c=1:size(fxmatrix,1)
            name = char(clustname(c));
            ni = nivector(c)
            fx = (fxmatrix(c, k))  %should be the rate for cell c at vel k.


            productme = (productme + (length(ni)+eps)*log(fx));

            expme = (expme) + (fx);
            % goes to next cell, same velocity


        end

        numcel(end+1) = (ni);
        % now have all cells at that location
        tmm = currend-currstart;


        productme
        tmm
        expme
      endprob(k) = (productme) + (-tmm.*expme); %IN

      end

      [val, idx] = (max(endprob));



[maxval] = find(endprob == max(endprob(:)));
  mp = max(endprob(:));

  endprob = exp(endprob-mp);
  conv = 1./sum(endprob(~isnan(endprob)), 'all');
  endprob = endprob.*conv; %matrix of percents


endproball = [endproball, endprob];



  percents(end+1) = max(endprob(:)); %finds confidence
  if length(maxval) > 1 %if probs are the sample, randomly pick one and print warning
     same = same+1;
     maxval = datasample(maxval, 1);
     maxval = datasample(maxval, 1);

  end

  currstart_vec(end+1) = currstart;
  currend_vec(end+1) = currend;



     newend = currend+tdecode;


      end


      num = num2str(r);
      name = strcat('rip', num);
      name = char(name);
      matrices.(name) = endproball;


      values = [maxx; maxy; percents; currstart_vec; currend_vec];
      all_decoded(:,1:length(values),r)= values;


end


zz = matrices;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RADON %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ripnames = fieldnames(matrices);
ripnum = length(ripnames);

for k = 1:ripnum
  name = char(ripnames(k));
  matrices_currentrip = matrices.(name);
  score_old = 0;
  slope = [];
  score = [];
  intercept = [];
  projection = [];

  timestep = 1/tdecode;


  [slope_new, intercept_new, score_new, projection_new]  = est_line_detect([(1:size(matrices_currentrip,2))], [1:size(matrices_currentrip,1)], matrices_currentrip);

  if score_new > score_old
    score_old = score_new;
    score = score_new;
    slope = slope_new;
    intercept = intercept_new;
    projection = projection_new;

    p = size(matrices_currentrip,2);
    y = (slope)*(1:p)+intercept;
    y = round(y);
  end
  slope_all(k) = slope;
  intercept_all(k) = intercept;
  score_all(k) =score;
end

radon_results = [score_all; slope_all; intercept_all];
