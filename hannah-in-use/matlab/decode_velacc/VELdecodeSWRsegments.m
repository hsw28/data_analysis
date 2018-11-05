function values = VELdecodeSWRsegments(SWRstartend, timevector, clusters, vel, t)
%decodes position in each SWR seperately. input the output for findripMUA.m


SWRstart = SWRstartend(1,:);
SWRend = SWRstartend(2,:);


tic
tsec = t;
t = 2000*t;

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



%%%NEW
starttime = decodetimevector(1);
endtime = decodetimevector(end);

m = starttime:t:endtime;


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


%%%%
binnedVelo = histcounts(avg_accel, 'BinWidth', 7);
binnedVelo = binnedVelo./sum(binnedVelo);
k = length(binnedVelo);
percentsum = 0;
while percentsum<.05
  percentsum = percentsum + binnedVelo(k);
  k = k-1;
end
totbin = k+1;
vbin = [0:7:totbin*7]

%7 with .05 is best so far








% for each cluster,find the firing rate at esch velocity range
j = 1;
fxmatrix = zeros(numclust, length(vbin));
while j <= numclust
    name = char(clustname(j));
    firingdata = clusters.(name);
    fxmatrix(j,:) = firingPerVel(asstime, assvel, clusters.(name), tsec, vbin, avg_accel);
    j = j+1;
end

fxmatrix


 %find prob the animal is each velocity DONT NEED BUT CAN BE USEFUL

probatvelocity = zeros(length(vbin),1);
binnedV = binVel(asstime, vel, t/2000, vbin);
legitV = find(binnedV<100);
for k = 1:length(vbin)
    numvel = find(binnedV == (k));
    probatvelocity(k) = length(numvel)./length(legitV);
end
probatvelocity



% permue times
  maxprob = [];
  spikenum = 1;
  times = [];
  perc = [];

%percents = zeros(length(timevector)-(rem(length(timevector), t)), length(vbin)) ;
percents = [];
nivector = zeros((numclust),1);
 r=1;
while r<=length(SWRstartend)
      %for the cluster, permute through the velocities
      endprob = [];


        for k = (1:length(vbin)) % six for the 6 groups of velocities
          %PERMUTE THROUGH THE CLUSTERS
          %productme = 1; OLD
          productme =0;
          expme = 0;
          c = 1;
          while c <= numclust
              size(numclust);
              name = char(clustname(c));
              ni = find(clusters.(name)>SWRstart(r) & clusters.(name)<=SWRend(r)); % finds index (number) of spikes in range time
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
          tmm = SWRend(r)-SWRstart(r);

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



            %if max(isinf(test)) == 1
            %endprob = exp(endprob-(max(endprob)*.2));
            %else
          %    endprob = test;
        %    end

            conv = 1./sum(endprob(~isnan(endprob)), 'all');

      endprob = endprob*conv;



        percents = vertcat(percents, endprob);

        maxprob(end+1) = idx;
        perc(end+1) = max(endprob);
        %maxprob(end+1) = find(max(endprob)); %finds most likely range: 1 is for 0-10, 2 for 10-30, etc
                                          % if I want probabilities need to make a matrix of endprobs instead of selecting max


        r =r+1;


end

%length(find(binnedV==4))

%ans = find(binnedV<50);
%[h,p,ci,stats] = ttest2(maxprob, binnedV);
probs = percents;


v = maxprob;

binnum = v;

k=length(vbin);
while k>0
  bin = find(v==k);
  if k<length(vbin)
    v(bin) = (vbin(k)+vbin(k+1))/2;
  elseif k==length(vbin)
    highestvel = find(vel(1,:)>vbin(end));
    highestvel = median(vel(1,highestvel));
    v(bin) = highestvel;
end
k = k-1;
end

values = [v; binnum; perc; SWRstart; SWRstart];

toc

if abs(length(values)-length(binnedV))<3
  cm = confusionmat(values(3,1:length(binnedV)), binnedV);
  plotConfMat(cm)
end
