function f = decodeshit(timevec, clusters, vel, t)

% decodes velocity  based on cell firing. t is bins in seconds
% returns [predictedV, actualV]
% for now make sure bins in binVel function are the same. will implement that as a variable later

t = 2000*t;
tm = 1;
assvel = assignvel(timevec, vel);
timevector = timevec(1:length(assvel));

%find number of clusters
clustname = (fieldnames(clusters))
numclust = length(clustname)

%bin the velocities
% for now let's bin velocity as 0-10, 10-30, 30-60, 60-100, 100+
%vbin = [10; 30; 60; 100];

vbin =  [0; 4; 8; 12; 16; 20; 24];

binnedV = binVel(timevec, vel, t/2000);


% for each cluster,find the firing rate at esch velocity range
j = 1;
fxmatrix = zeros(numclust, length(vbin));
while j <= numclust
    name = char(clustname(j));
    fxmatrix(j,:) = firingPerVel(timevector, assvel, clusters.(name), t./2000);
    j = j+1;
end




% find prob the animal is each velocity
probatvelocity = zeros(length(vbin),1);
for k = 1:length(vbin)
    numvel = find(binnedV == (k));
    probatvelocity(k) = length(numvel)./length(binnedV);
end

%for k = 1:length(vbin)
%    if k == 1
%        probatvelocity(1,1) = length(find(assvel>=vbin(1) & assvel<=vbin(2)))./length(assvel);
%    elseif k>1 & k<length(vbin)
%      probatvelocity(k,1) = length(find(assvel>vbin(k) & assvel<=vbin(k+1)))./length(assvel);
%    elseif k==length(vbin)
%      probatvelocity(end,1) = length(find(assvel>vbin(length(vbin))))./length(assvel);
%    end
%end
probatvelocity

% permue times
  maxprob = [];
  spikenum = 1;

while tm <= length(timevector)-(rem(length(timevector), t))
      %for the cluster, permute through the velocities
      endprob = [];

        for k = (1:length(probatvelocity)) % six for the 6 groups of velocities
          %PERMUTE THROUGH THE CLUSTERS
          %productme = 1; OLD
          productme =0;
          expme = 0;
          c = 1;
          while c <= numclust
              size(numclust);
              name = char(clustname(c));
              ni = find(clusters.(name)>timevector(tm) & clusters.(name)<timevector(tm+t)); % finds index (number) of spikes in range time
              fx = (fxmatrix(c, k));  %should be the rate for cell c at vel k.


              %fxni = (fx^length(ni)); OLD
              %productme = productme*fxni; OLD

               productme = (productme + length(ni)*log(fx));
              %productme = productme + log((fx^length(ni)));

              expme = (expme) + (fx);
              c = c+1; % goes to next cell, same velocity

          end
          % now have all cells at that velocity
          tmm = t./2000;

          %eq = (productme.* exp(-tmm.*expme)); OLD

          % need to multiple by probabily of being at that velocity

          %endprob(end+1) = probatvelocity(k) .* eq;

          endprob(end+1) = log(probatvelocity(k)) + (productme) + (-tmm.*expme); %NEW


        %  if max(isinf(endprob)) ==1
        %      warning('youve got an infinity')
              %length(ni)
              %log(productme) %this is inf
          %elseif mean(endprob) ==0
          %    warning('youve got all zeros')
          %    endprob
          %end



        end
      endprob;
        [val, idx] = (max(endprob));
        maxprob(end+1) = idx;
        %maxprob(end+1) = find(max(endprob)); %finds most likely range: 1 is for 0-10, 2 for 10-30, etc
                                              % if I want probabilities need to make a matrix of endprobs instead of selecting max
    tm = tm+t;
end

[h,p,ci,stats] = ttest2(maxprob, binnedV)
f = [maxprob; binnedV];
