function [values probs] = decodeshitSkinner(time, cueOn, clusters, tdecode, tsegment, varargin)

% decodes velocity  based on cell firing. tdecode is bins in seconds you want the results decoded in (so like .015 for ripples).
%tsegment is segments you want skinner rates calculated in (for example 8sec for all cue time unchunked)
% for varargin you can insert  firing rate at esch velocity range from firingPerPhase
%
% returns [predictedV, actualV]
% for now make sure bins in binVel function are the same. will implement that as a variable later
%
%
% to plot: imagesc([minx maxx], [miny maxy], decoded.probs')
% ex: imagesc([times(1) times(end)], [0 3], probs')
% can plot a line at points with vline(skinner19)
%
% to plot actual velocity over it:
% temp = binning(assvel(1,:)', ceil(length(assvel)/length(decoded.probs)));
% temp = temp/ceil(length(assvel)/length(decoded.probs));
% plot(temp, 'LineWidth',1.5, 'Color', 'w');



[c startindex] = min(abs(time-cueOn(1)));
[c endindex] = min(abs(time-cueOn(end)));
%timevector = time(startindex:(endindex+(17*2000)));
timevector = time(startindex:end);

t = tdecode;
t = 2000*t;
tm = 1;

%NEED TO CUT TIME VECTOR TO CORRECT TIME?

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);

%BIN
%((8/tsegment)*2)+2 for 8 seconds per cue/reward divided by number of seconds you want to segment, plus 2 (one for intertrial, one for post trial)
numofbins = ((8/tsegment)*2)+1;


% for each cluster,find the firing rate at esch velocity range
if size(varargin) > 0
  fxmatrix = cell2mat(varargin);
else
  fxmatrix = firingPerPhase(timevector, cueOn, clusters, tsegment);
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

%while tm <= 48000
%COMMENT BACK
numcel = [];

while tm < (length(timevector)-t)
      %for the cluster, permute through the different conditions
      endprob = [];

        for k = (1:numofbins) %each bin for a condition
          %PERMUTE THROUGH THE CLUSTERS
          productme =0;
          expme = 0;
          c = 1;

          while c <= numclust

              name = char(clustname(c));


              ni = find(clusters.(name)>timevector(tm) & clusters.(name)<timevector(tm+t)); % finds index (number) of spikes in range time


              fx = (fxmatrix(c, k));  %should be the rate for cell c at condition k.

              if fx ~= 0
                productme = productme + length(ni)*log(fx);  %IN
                %productme = productme + (fx.^length(ni)); %OUT
              else
                fx = .00000000000000000000001;
                productme = productme + length(ni)*log(fx);
              end





              expme = (expme) + (fx);
              c = c+1; % goes to next cell, same condition

          end
          numcel(end+1) = length(ni);
          % now have all cells at that velocity
          tmm = t./2000;

       %endprob(end+1) = productme*exp(-tmm.*expme); %out

     endprob(end+1) = (productme) + (-tmm.*expme); %IN


            %end


        end


        [val, idx] = (max(endprob));

      endprob = exp(endprob);
        conv = 1./sum(endprob);
        endprob = endprob*conv;


        percents = vertcat(percents, endprob);

        maxprob(end+1) = idx;
        times(end+1) = timevector(tm);

    tm = tm+t;
    tm = tm+(t/4); %for overlap?
end

%[h,p,ci,stats] = ttest2(maxprob, binnedV);
%probs = percents;

if tsegment < 8
    seg = 8/tsegment;
    maxprob(find(maxprob<=seg)) = 1;
    maxprob(find(maxprob>seg & maxprob<=(2*seg))) = 2;
    maxprob(find(maxprob>(2*seg))) = 3;
end



probs = percents;
values = [maxprob; times];
