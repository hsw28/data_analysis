function [values probs] = decodeshitSkinnerCueRew(time, cueOn, clusters, tdecode, tsegment)

% decodes velocity  based on cell firing. tdecode is bins in seconds you want the results decoded in (so like .015 for ripples).
%tsegment is segments you want skinner rates calculated in (for example 8sec for all cue time unchunked)
%
% returns [predictedV, actualV]
% for now make sure bins in binVel function are the same. will implement that as a variable later
%
%
% to plot: imagesc([minx maxx], [miny maxy], decoded.probs')
% ex: imagesc([0 length(decoded.probs)], [2 24], decoded.probs')
%
% to plot actual velocity over it:
% temp = binning(assvel(1,:)', ceil(length(assvel)/length(decoded.probs)));
% temp = temp/ceil(length(assvel)/length(decoded.probs));
% plot(temp, 'LineWidth',1.5, 'Color', 'w');


[c startindex] = min(abs(time-cueOn(1)));
[c endindex] = min(abs(time-cueOn(end)));
timevector = time(startindex:(endindex+(17*2000)));

t = tdecode;
t = 2000*t;
tm = 1;

foodOn = cueOn+8;
foodEnd = foodOn+8;
cueOnindex=[];
foodOnindex=[];
foodEndindex=[];
for k=1:length(cueOn)
    [c cueindex] = min(abs(time-cueOn(k)));
    [c foodindex] = min(abs(time-foodOn(k)));
    [c endindex] = min(abs(time-foodEnd(k)));
    cueOnindex(end+1) = cueindex;
    foodOnindex(end+1) = foodindex;
    foodEndindex(end+1) = endindex;
end

%turns all time into just cue and reward periods
newtime = [];
for z=1:length(cueOn)
    newtime = horzcat(newtime, time(cueOnindex(z):foodEndindex(z)));
end

testend1 = time(end)
teststart1 = time(1)
time = newtime;
length(time);
testend = time(end)
teststart = time(1)




%find number of clusters
clustname = (fieldnames(clusters))
numclust = length(clustname)

%BIN
%((8/tsegment)*2)+2 for 8 seconds per cue/reward divided by number of seconds you want to segment, plus 2 (one for intertrial, one for post trial)
numofbins = ((8/tsegment)*2);


% for each cluster,find the firing rate at esch velocity range
j = 1;
fxmatrix = zeros(numclust, numofbins);
while j <= numclust
    name = char(clustname(j));
    fxmatrix(j,:) = firingPerPhaseCueRew(timevector, cueOn, clusters.(name), tsegment);
    j = j+1;
end

fxmatrix


% find prob the animal is each velocity
%probatvelocity = zeros(length(vbin),1);
%legitV = find(binnedV<100);
%for k = 1:length(vbin)
%    numvel = find(binnedV == (k));
%    probatvelocity(k) = length(numvel)./length(legitV);
%end
%probatvelocity

% permue times
  maxprob = [];
  spikenum = 1;
  times = [];

%percents = zeros(length(timevector)-(rem(length(timevector), t)), length(vbin)) ;
percents = [];

t = tdecode;
t = 2000*t;
tm = 1;
debug = 0;

length(time)

while tm <= length(time)-(rem(length(time), t))
      %for the cluster, permute through the velocities
      endprob = [];

        for k = (1:numofbins) % six for the groups of times
          %PERMUTE THROUGH THE CLUSTERS
          productme =0;
          expme = 0;
          c = 1;
          while c <= numclust
              name = char(clustname(c));
              ni = find(clusters.(name)>=time(tm) & clusters.(name)<time(tm+t)); % finds index (number) of spikes in range time
              %time(tm)
              %time(tm+t)
              %length(ni)
              fx = (fxmatrix(c, k))  %should be the rate for cell c at vel k.

              if fx == 0
                  productme = (productme + length(ni)*-1000000000); %is this right?
              else
               productme = (productme + length(ni)*log(fx));
             end

              expme = (expme) + (fx);
              c = c+1; % goes to next cell, same velocity

          end
          % now have all cells at that velocity
          tmm = t./2000;

          %IF YOU WANT TO MULTIPLY BY PROB OF LOCATION COMMENT OUT FIRST LINE AND IN SECOND LINE

        endprob(end+1) = (productme) + (-tmm.*expme); %NEW
        productme = productme;
        otherthing = (-tmm.*expme);
          %endprob(end+1) = log(probatvelocity(k)) + (productme) + (-tmm.*expme); %NEW

        end


        [val, idx] = (max(endprob));

        %for an infinity problem
        %nums = isfinite(endprob);
        %nums = find(nums == 1);
      %endprob = endprob(nums);

        %test = exp(endprob);
        %    if max(isinf(test)) == 1
        %    endprob = exp(endprob-(max(endprob)*.2));
        %    else
        %      endprob = test;
        %    end

        conv = 1./sum(endprob);
      endprob = endprob*conv;



        percents = vertcat(percents, endprob);

        maxprob(end+1) = idx;
        %maxprob(end+1) = find(max(endprob)); %finds most likely range: 1 is for 0-10, 2 for 10-30, etc
                                          % if I want probabilities need to make a matrix of endprobs instead of selecting max
        times(end+1) = time(tm);

    tm = tm+t;
end

%[h,p,ci,stats] = ttest2(maxprob, binnedV);
%probs = percents;


%values = [maxprob; binnedV, times'];
values = [maxprob; times];


%ans = find(binnedV<50);
probs = percents;
%values = [maxprob; binnedV, times'];
values = [maxprob; times];
