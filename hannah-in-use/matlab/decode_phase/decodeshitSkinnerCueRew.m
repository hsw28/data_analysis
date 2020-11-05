function [values probs ff] = decodeshitSkinnerCueRew(time, cueOn, clusters, tdecode, tsegment)

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
tdecodesec = tdecode;
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
cueOnTime = time(cueOnindex);
%for z=1:length(cueOn)
%    newtime = horzcat(newtime, time(cueOnindex(z):foodEndindex(z)));
%end





%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);

%BIN
%((8/tsegment)*2)+2 for 8 seconds per cue/reward divided by number of seconds you want to segment, plus 2 (one for intertrial, one for post trial)
%JK no intertrial here so scrap that
numofbins = ((8/tsegment)*2);


% for each cluster,find the firing rate at esch velocity range
j = 1;
fxmatrix = zeros(numclust, numofbins);
while j <= numclust
    name = char(clustname(j));
    fxmatrix(j,:) = firingPerPhaseCueRew(timevector, cueOn, clusters.(name), tsegment);
    j = j+1;
end



ff = fxmatrix;
fprintf('eliminated for not spiking enough')
eliminate = find(fxmatrix(:,1)<.05 | fxmatrix(:,2)<.05)

fprintf('eliminated for no change from cue to reward')
gooddiff = ((fxmatrix(:,1)-fxmatrix(:,2)) ./ ((fxmatrix(:,1)+fxmatrix(:,2))));
eliminate = find(abs(gooddiff)<.2)




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

maxprobALL = [];
timesALL = [];
percentsALL = [];


for z=1:length(cueOnTime)

currtime = cueOnTime(z);
maxprobs = [];


while currtime+tdecodesec <= (cueOnTime(z))+16
      %for the cluster, permute through the velocities
      endprob = [];



        for k = (1:numofbins) % six for the groups of times
          %PERMUTE THROUGH THE CLUSTERS
          productme =0;
          expme = 0;
          c = 1;

          for =1:length(fxmatrix)
              name = char(clustname(c));
              ni = find(clusters.(name)>=currtime & clusters.(name)<(currtime+tdecodesec)); % finds index (number) of spikes in range time

              fx = (fxmatrix(c, k));  %should be the rate for cell c at vel k.


              productme = (productme + (length(ni)+eps)*log(fx));

              expme = (expme) + (fx);
              % goes to next cell, same velocity


          end
          % now have all cells at that velocity
          tmm = tdecodesec;

          %IF YOU WANT TO MULTIPLY BY PROB OF LOCATION COMMENT OUT FIRST LINE AND IN SECOND LINE


        endprob(end+1) = (productme) + (-tmm.*expme); %NEW





        end


        [val, idx] = (max(endprob));




    mp = max(endprob(:));

    endprob = exp(endprob-mp);
    conv = 1./sum(endprob(~isnan(endprob)), 'all');
    endprob = endprob.*conv; %matrix of percents




        percents = vertcat(percents, endprob);

        maxprob(end+1) = idx;
        %maxprob(end+1) = find(max(endprob)); %finds most likely range: 1 is for 0-10, 2 for 10-30, etc
                                          % if I want probabilities need to make a matrix of endprobs instead of selecting max

      maxprobALL(end+1) = idx;
      timesALL(end+1) = currtime;




    currtime = currtime+tdecodesec;

end



end

%[h,p,ci,stats] = ttest2(maxprob, binnedV);
%probs = percents;


size(maxprobALL)
size(timesALL)
%values = [maxprob; binnedV, times'];
values = [maxprobALL; timesALL];


%ans = find(binnedV<50);
probs = percents;
%values = [maxprob; binnedV, times'];
values = [maxprobALL; timesALL];


types = (8./tsegment)*2;
accuracies = NaN(types,2)
for f = 1:types
  currseg = (f:types:length(probs));
  accuracies(f,1) = f;
  accuracies(f,2) = length(find(values(1,currseg) == f))./length(currseg);
end
accuracies



%odds = (1:2:length(probs));
%evens = (2:2:length(probs));
%fprintf('cue accuracy')
%length(find(values(1,odds) == 1))./length(odds)
%fprintf('reward accuracy')
%length(find(values(1,evens) == 2))./length(evens)
