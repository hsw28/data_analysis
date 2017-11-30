function f = decodeshit(timevector, clusters, vel, t)

% decodes velocity  based on cell firing. t is bins in seconds

t = 2000*t;
tm = 1;
assvel = assignvel(timevector, vel);
timevector = timevector(1:length(assvel));

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);

%bin the velocities
% for now let's bin velocity as 0-10, 10-30, 30-60, 60-100, 100+
%vbin = [10; 30; 60; 100];

vbin =  [10; 12; 14; 16; 18; 20];


% for each cluster,find the firing rate at esch velocity range
j = 1;
fxmatrix = zeros(numclust, length(vbin));
while j <= numclust
    name = char(clustname(j));
    fxmatrix(j,:) = firingPerVel(timevector, vel, clusters.(name), 2000./t);
    j = j+1;
end




% find prob the animal is each velocity
probatvelocity = zeros(length(vbin),1);
probatvelocity(1,1) = length(find(assvel>=vbin(1) & assvel<=vbin(2)))./length(assvel);
probatvelocity(2,1) = length(find(assvel>vbin(2) & assvel<=vbin(3)))./length(assvel);
probatvelocity(3,1) = length(find(assvel>vbin(3) & assvel<=vbin(4)))./length(assvel);
probatvelocity(4,1) = length(find(assvel>vbin(4) & assvel<=vbin(5)))./length(assvel);
probatvelocity(5,1) = length(find(assvel>vbin(5) & assvel<=vbin(6)))./length(assvel);
probatvelocity(end,1) = length(find(assvel>vbin(length(vbin))))./length(assvel);
probatvelocity

% permue times
  maxprob = [];
  spikenum = 1;

while tm <= length(timevector)-(rem(length(timevector), t))
      %for the cluster, permute through the velocities
      endprob = [];

        for k = (1:length(probatvelocity)) % six for the 6 groups of velocities
          %PERMUTE THROUGH THE CLUSTERS
          productme = 1;
          expme = 0;
          c = 1;
          while c <= numclust
              name = char(clustname(c));
              ni = find(clusters.(name)>timevector(tm) & clusters.(name)<timevector(tm+t)); % finds index (number) of spikes in range time
              fx = (fxmatrix(c, k));  %should be the rate for cell c at vel k.
              fxni = (fx^length(ni));
              productme = productme*fxni;
              expme = expme + fx;
              c = c+1; % goes to next cell, same velocity

          end
          % now have all cells at that velocity
          tmm = t./2000;
          eq = productme.* exp(-tmm.*expme);
          % need to multiple by probabily of being at that velocity
        %ADD BACK  endprob(end+1) = probatvelocity(k) .* eq;
      endprob(end+1) = eq; % TAKE AWAY

        end
        endprob;
        [val, idx] = (max(endprob));
        maxprob(end+1) = idx;
        %maxprob(end+1) = find(max(endprob)); %finds most likely range: 1 is for 0-10, 2 for 10-30, etc
                                              % if I want probabilities need to make a matrix of endprobs instead of selecting max
    tm = tm+t;
end


f =maxprob;
