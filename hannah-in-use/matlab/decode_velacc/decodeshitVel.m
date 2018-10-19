function [values probs] = decodeshitVel(timevector, clusters, vel, tdecode, t)

% decodes velocity  based on cell firing. t is bins in seconds
% returns [predictedV, actualV]
% for now make sure bins in binVel function are the same. will implement that as a variable later
%
%
%NEED TO PUT TIMES WITH THE OUTPUT OR IT GETS SUPER CONFUSING. DO THIS
%
% to plot: imagesc([minx maxx], [miny maxy], decoded.probs')
% ex: imagesc([0 length(decoded.probs)], [2 24], decoded.probs')
%
% to plot actual velocity over it:
% temp = binning(assvel(1,:)', ceil(length(assvel)/length(decoded.probs)));
% temp = temp/ceil(length(assvel)/length(decoded.probs));
% plot(temp, 'LineWidth',1.5, 'Color', 'w');
tic
tsec = t;
t = 2000*t;
tdecodesec = tdecode;
tdecode = tdecode*2000;
tm = 1;

mintime = vel(2,1)
maxtime = vel(2,end)

[c indexmin] = (min(abs(timevector-mintime)));
[c indexmax] = (min(abs(timevector-maxtime)));
decodetimevector = timevector(indexmin:indexmax);

assvel = assignvel(decodetimevector, vel);
asstime = assvel(2,:);

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);

%bin the velocities
%vbin = [0; 8; 16; 24; 32; 40; 48; 54]; %MOST USED, used for 19
%vbin = [0; 4; 8; 12; 16; 20; 24; 28]; %use for 17
%vbin = [0; 3; 6; 9; 12; 15; 18; 21; 24] %for 15, gets .17 corr at .5
%vbin = [0; 7; 14; 21; 28]; %for 15, gets .11 corr
%vbin = [0; 4; 8; 12; 16; 20; 24] %for 15, gets .15 corr
%vbin = [0; 5; 10; 15; 20; 25]  %for 15, gets .12 corr
%vbin = [0; 7; 14; 21; 28; 35] %for 15 gets .09 corr
%vbin = [0; 5; 10; 15; 20; 25]  %for 15, gets .12 corr
%vbin = [0; 6; 12; 18; 24; 30];
%vbin = [0; 5; 10; 15; 20; 25]  %for 15, gets .12 corr
%vbin = [0; 5; 10; 15; 20; 25; 30]
%vbin = [0; 4; 8; 12; 16; 20; 24; 28]
%vbin = [0; 3; 6; 9; 12; 15; 18; 21; 24; 28]
%vbin = [0; 4; 8; 12; 16; 20]
%vbin = [0; 10; 20; 30; 40; 50; 60; 70; 80; 90; 100]
%vbin = [0; 10; 20; 30; 40; 50; 60]
%vbin = [0; 10; 20; 30; 40] best yet for 15
%vbin = [0; 5; 10; 15; 20; 25; 30; 35; 40]
%vbin = [0; 5; 10; 15; 20; 25; 30; 35] %getting there
%vbin = [0; 6; 12; 18; 24; 30; 36]
%vbin = [0; 8; 16; 24; 32; 40]
%vbin = [0; 4; 8; 12; 16; 20; 24; 28; 32; 36; 40; 44]
%vbin = [0; 6; 12; 18; 24; 30; 36]
%vbin = [0; 7; 14; 21; 28; 35; 42] %getting there
%vbin = [0; 8; 16; 24; 32; 40; 48];
%vbin = [0; 7; 14; 21; 28]
%vbin = [0; 2; 4; 6; 10; 14]
%vbin = [0; 2; 4; 6; 10; 15; 40]
%vbin = [0; 2; 4; 6; 10; 15; 35]
%vbin = [0; 3; 6; 9; 12; 15; 18; 21; 24; 27]
%vbin = [0; 2; 4; 6; 8; 10; 12; 14; 16; 18]
%vbin = [0; 2; 4; 6; 8; 10; 12; 50]
%vbin = [0; 2; 6; 14; 30; 62]
%vbin = [0; 3; 6; 12; 25; 55]
%vbin = [0; 3; 6; 12; 25; 40; 55]
%vbin = [0; 3; 6; 12; 25; 33; 40; 48; 55]
%vbin = [0; 3; 6; 12; 25; 33; 40; 44; 48; 55]
%vbin = [0; 3; 6; 12; 25; 33; 40; 44; 48]
%vbin = [0; 3; 6; 12; 25; 33; 40; 44]
%vbin = [0; 3; 6; 12; 25; 33; 40]
%vbin = [0; 6; 12; 25; 33; 40]                %not bad at 1 sec
%vbin = [0; 6; 12; 18; 24; 30]                %good at 1 sec
%vbin = [0; 3; 6; 12; 15; 18; 21; 24; 27; 30]
%vbin = [0; 4; 8; 12; 16; 20; 24; 28; 32]
%vbin = [0; 4; 8; 12; 16; 24; 28; 32]
%vbin = [0; 5; 10; 15; 20; 25; 30]             %good at 1 sec
%vbin = [0; 5; 10; 15; 20; 25; 30; 35]
%vbin = [0; 6; 12; 18; 24; 30; 36]
%vbin = [0; 3; 6; 12; 18; 24; 30]   %also not bad
%vbin = [0; 6; 12; 18; 24; 30]; %23.67
%vbin = [0; 6; 12; 18; 24; 30; 36]; %21
%vbin = [0; 4; 8; 12; 16; 20; 24; 28]; %18
%vbin = [0; 5; 10; 15; 20; 25; 30]; %21 %but might look better than other 21 and 23
%vbin = [0; 5; 10; 15; 20; 25; 30; 35]; %19
%vbin = [0; 5; 10; 15; 20; 25; 30]
%vbin = [0; 6; 12; 18; 24; 30]

vbin = [0; 7; 14; 21; 28; 35]  %best



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
binnedV = binVel(asstime, vel, t/2000);
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

%percents = zeros(length(timevector)-(rem(length(timevector), t)), length(vbin)) ;
percents = [];

while tm <= length(timevector)-(rem(length(timevector), tdecode)) & (tm+tdecode) < length(timevector)
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
              ni = find(clusters.(name)>timevector(tm) & clusters.(name)<=timevector(tm+tdecode)); % finds index (number) of spikes in range time
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

        test = exp(endprob);
            if max(isinf(test)) == 1
            endprob = exp(endprob-(max(endprob)*.2));
            else
              endprob = test;
            end

        conv = 1./sum(endprob);
      endprob = endprob*conv;



        percents = vertcat(percents, endprob);

        maxprob(end+1) = idx;
        %maxprob(end+1) = find(max(endprob)); %finds most likely range: 1 is for 0-10, 2 for 10-30, etc
                                          % if I want probabilities need to make a matrix of endprobs instead of selecting max
        times(end+1) = timevector(tm);

        if tdecodesec>=.25
          tm = tm+(tdecode/2);
        else
          tm = tm+tdecode;
        end


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

values = [v; times; binnum];

toc
%[h,p,ci,stats] = ttest2(maxprob, binnedV)
%probs = percents;
%values = [maxprob; binnedV];
