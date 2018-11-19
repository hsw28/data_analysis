function [values probs] = decodeshitACC(timevector, clusters, acc, tdecode, t)

% decodes velocity  based on cell firing. t is bins in seconds
% returns [predictedV, actualV]
% for now make sure bins in binVel function are the same. will implement that as a variable later

%NEED TO PUT TIMES WITH THE OUTPUT OR IT GETS SUPER CONFUSING. DO THIS



vel = acc;


%vbin = [3; 6; 9; 12; 15; 18];
%vbin = [-12, -6, -4, 4, 6, 12]
vbin = [-4, 4]


tsec = t;
t = 2000*t;
tdecodesec = tdecode;
tdecode = tdecode*2000;
tm = 1;

mintime = vel(2,1);
maxtime = vel(2,end);


[c indexmin] = (min(abs(timevector-mintime)));
[c indexmax] = (min(abs(timevector-maxtime)));
decodetimevector = timevector(indexmin:indexmax);


assvel = assignvel(decodetimevector, vel);
asstime = assvel(2,:);

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname)


%FIGURE THIS OUT
%assvel(1,:) = abs(assvel(1,:));


starttime = decodetimevector(1);
endtime = decodetimevector(end);

m = starttime:t:endtime;

%%NEW
duration = endtime-starttime;
 time_v = starttime:tsec:endtime;
 if mod(duration,tsec) ~= 0
     time_v = time_v(1:end-1);
 end
 m = length(time_v);
%avg_accel = zeros(m,1);
avg_accel = [];

for i = 1:m
  starttime+tsec*(i-1);
  starttime+tsec*i;
    wanted = find(decodetimevector > starttime+tsec*(i-1) & decodetimevector < (starttime+tsec*i));

    avg_accel(end+1) = mean(assvel(1,wanted)); % finds average vel within times

end
size(avg_accel);
avg_accel = avg_accel';
%%%





% for each cluster,find the firing rate at esch velocity range
j = 1;
fxmatrix = zeros(numclust, length(vbin)+1);
while j <= numclust
    name = char(clustname(j));
    firingdata = clusters.(name);
    fxmatrix(j,:) = firingPerAcc(asstime, assvel, clusters.(name), tsec, vbin, avg_accel);
    j = j+1;
end
fxmatrix




% find prob the animal is each velocity
probatvelocity = zeros(length(vbin),1);
binnedV = binAcc(asstime, vel, t/2000, vbin);
for k = 1:(length(vbin)+1)
    numvel = find(binnedV == (k));
    probatvelocity(k) = length(numvel)./length(binnedV);

end
probatvelocity


%for k = 1:length(vbin)
%    if k == 1
%        probatvelocity(1,1) = length(find(assvel>=vbin(1) & assvel<=vbin(2)))./length(assvel);
%    elseif k>1 & k<length(vbin)
%      probatvelocity(k,1) = length(find(assvel>vbin(k) & assvel<=vbin(k+1)))./length(assvel);
%    elseif k==length(vbin)
%      probatvelocity(end,1) = length(find(assvel>vbin(length(vbin))))./length(assvel);
%    end
%end


% permue times
  maxprob = [];
  spikenum = 1;
    times = [];
    perc = [];

%percents = zeros(length(timevector)-(rem(length(timevector), t)), length(vbin)) ;
percents = [];
nivector = zeros((numclust),1);

while tm <= length(timevector)-(rem(length(timevector), tdecode))  & (tm+tdecode) < length(timevector)
      %for the cluster, permute through the velocities
      endprob = [];

        for k = (1:length(vbin)+1) % six for the 6 groups of velocities
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

              if fx ~= 0
                productme = productme + length(ni)*log(fx);  %IN
              else
                fx = .00000000000000000000001;
                productme = productme + length(ni)*log(fx);

              end

              %fxni = (fx^length(ni)); OLD
              %productme = productme*fxni; OLD

               productme = (productme + length(ni)*log(fx));
              %productme = productme + log((fx^length(ni)));

              expme = (expme) + (fx);
              c = c+1; % goes to next cell, same velocity

          end
          % now have all cells at that velocity
          tmm = t./2000;

          %IF YOU WANT TO MULTIPLY BY PROB OF LOCATION COMMENT OUT FIRST LINE AND IN SECOND LINE
          endprob(end+1) = (productme) + (-tmm.*expme); %NEW
          %endprob(end+1) = log(probatvelocity(k)) + (productme) + (-tmm.*expme); %NEW


        %  if max(isinf(endprob)) ==1
        %      warning('youve got an infinity')
              %length(ni)
              %log(productme) %this is inf
          %elseif mean(endprob) ==0
          %    warning('youve got all zeros')
          %    endprob
          %end



        end

        [val, idx] = (max(endprob));

        nums = isfinite(endprob);
        nums = find(nums == 1);
      endprob = endprob(nums);

      mp = max(endprob(:))-12;

      endprob = exp(endprob-mp);

        %test = exp(endprob);
        %    if max(isinf(test)) == 1
        %    endprob = exp(endprob-(max(endprob)*.2));
        %    else
        %      endprob = test;
        %    end

          conv = 1./sum(endprob(~isnan(endprob)), 'all');
      endprob = endprob*conv;


        percents = vertcat(percents, endprob);

        maxprob(end+1) = idx;
        perc(end+1) = max(endprob);
        %maxprob(end+1) = find(max(endprob)); %finds most likely range: 1 is for 0-10, 2 for 10-30, etc
                                    % if I want probabilities need to make a matrix of endprobs instead of selecting max
      times(end+1) = timevector(tm);
      if tdecodesec>=.25
        tm = tm+(tdecode/2);
      else
        tm = tm+tdecode;
      end
end


probs = percents;


v = maxprob;

binnum = v;
vnew = zeros(length(v),1);
k=length(vbin)+1
while k>0
  bin = find(v==k);
  if k==length(vbin)+1
    highestvel = find(vel(1,:)>vbin(end));
    highestvel = median(vel(1,highestvel));
    vnew(bin) = highestvel;
  elseif k==1
    lowestvel = find(vel(1,:)<vbin(1));
    lowestvel = median(vel(1,lowestvel));
    vnew(bin) = lowestvel;
  else % k<length(vbin)+1 & k>1
      vnew(bin) = (vbin(k-1)+vbin(k))/2;

end
k = k-1;
end


values = [vnew'; times; binnum; perc];

figure
if abs(length(values)-length(binnedV))<3
  size(values)
  size(binnedV)
  cm = confusionmat(values(3,1:length(binnedV)), binnedV(1,:));
  plotConfMat(cm)
end
