function [values probs] = decodeshitVel(timevec, clusters, vel, t)

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

t = 2000*t;
tm = 1;
assvel = assignvel(timevec, vel);
timevector = timevec(1:length(assvel));

%find number of clusters
clustname = (fieldnames(clusters))
numclust = length(clustname)

%bin the velocities
% for now let's bin velocity as 0-10, 10-30, 30-60, 60-100, 100+


%vbin = [10; 15; 20; 25; 30]; 0.7578
%vbin = [0; 4; 8; 12; 16; 20];
%vbin = [0; 5; 10; 15; 20; 25];
%vbin = [0; 5; 10; 15; 30; 45];
%vbin = [0; 8; 16; 24; 32; 40]; A
%vbin = [0; 10; 20; 30; 40; 50]; %B
vbin = [0; 10; 20; 30; 40]; %C


binnedV = binVel(timevec, vel, t/2000);


% for each cluster,find the firing rate at esch velocity range
j = 1;
fxmatrix = zeros(numclust, length(vbin));
while j <= numclust
    name = char(clustname(j));
    fxmatrix(j,:) = firingPerVel(timevector, assvel, clusters.(name), t./2000);
    j = j+1;
end

fxmatrix


 %find prob the animal is each velocity DONT NEED BUT CAN BE USEFUL
probatvelocity = zeros(length(vbin),1);
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

while tm <= length(timevector)-(rem(length(timevector), t)) & (tm+t) < length(timevector)
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

    tm = tm+(t/2); %for overlap?

end

%length(find(binnedV==4))

%ans = find(binnedV<50);
%[h,p,ci,stats] = ttest2(maxprob, binnedV);
probs = percents;


%values = [maxprob; binnedV, times'];
%v = [maxprob; binnedV];
v = maxprob;
%vbin = [0; 10; 15; 20; 30; 40];

bin1 = find(v==1);
bin2 = find(v==2);
bin3 = find(v==3);
bin4 = find(v==4);
bin5 = find(v==5);
%bin6 = find(v==6);
%bin7 = find(v==7);
%bin8 = find(v==8);
%bin9 = find(v==9);
%bin10 = find(v==10);
v(bin1) = (vbin(1)+vbin(2))/2;
v(bin2) = (vbin(2)+vbin(3))/2;
v(bin3) = (vbin(3)+vbin(4))/2;
v(bin4) = (vbin(4)+vbin(5))/2;
%v(bin5) = (vbin(5)+vbin(6))/2;
%v(bin6) = (vbin(6)+vbin(7))/2;
%v(bin7) = (vbin(7)+vbin(8))/2;
%v(bin8) = (vbin(8)+vbin(9))/2;
%v(bin9) = (vbin(9)+vbin(10))/2;

highestvel = find(vel(1,:)>vbin(5));
highestvel = median(vel(1,highestvel));
v(bin5) = highestvel;

size(v)
size(times)
values = [v; times];


%[h,p,ci,stats] = ttest2(maxprob, binnedV)
%probs = percents;
%values = [maxprob; binnedV];
