function f = decodeshit(timevector, clusters, vel)

% define a time window, see how often cells spike during that time window
% based on average firing rate at different velocities, estimate velocity

% permute through times, then velocities, then clusters

% set time window
t = 1000;
tm = 1;

assvel = assignvel(timevector, vel);

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);

%bin the velocities
% for now let's bin velocity as 0-10, 10-30, 30-60, 60-100, 100+
%vbin = [10; 30; 60; 100];

% for each cluster,find the firing rate at esch velocity range
j = 1;
fxmatrix = zeros(numclust, 6);
while j <= numclust
    name = char(clustname(j));
    fxmatrix(j,:) = firingPerVel(timevector, vel, clusters.(name), 2000./t);
    j = j+1;
end


vbin = [0; 5; 10; 20; 50; 100];
vbin = [0; 6; 10; 15; 25; 100];

% find prob the animal is each velocity
probatvelocity = zeros(6,1);
probatvelocity(1,1) = length(find(assvel>=vbin(1) & assvel<=vbin(2)))./length(assvel);
probatvelocity(2,1) = length(find(assvel>vbin(2) & assvel<=vbin(3)))./length(assvel);
probatvelocity(3,1) = length(find(assvel>vbin(3) & assvel<=vbin(4)))./length(assvel);
probatvelocity(4,1) = length(find(assvel>vbin(4) & assvel<=vbin(5)))./length(assvel);
probatvelocity(5,1) = length(find(assvel>vbin(5) & assvel<=vbin(6)))./length(assvel);
probatvelocity(6,1) = length(find(assvel>vbin(6)))./length(assvel);


% permue times
  maxprob = [];
while tm <= length(timevector)-(rem(length(timevector), t))
      %for the cluster, permute through the velocities
      endprob = [];
        for k = (1:6) % five for the 5 groups of velocities
          %PERMUTE THROUGH THE CLUSTERS
          c = 1;
          prob = 1;
          while c <= numclust
              name = char(clustname(c));
              ni = find(clusters.(name)>timevector(tm) & clusters.(name)<timevector(tm+1000)); % finds index of spikes in range time
              % must find tambda
              % lambda = time window * firing rate at velocity
              % find cell firing rate at velocity
              sumfx = (fxmatrix(c, k));  %should be the rate for cell c at vel k. i think this is lambda
              newprob = poisspdf(length(ni),sumfx); % finds poisson
              prob = prob*newprob;
              c = c+1; % goes to next cell, same velocity

          end
          % now have all cells at that velocity multiplied
          % need to multiple by probabily of being at that velocity
        endprob(end+1) = prob .* probatvelocity(k);
        end

      endprob = endprob';
        [val, idx] = (max(endprob));
        maxprob(end+1) = idx;
        %maxprob(end+1) = find(max(endprob)); %finds most likely range: 1 is for 0-10, 2 for 10-30, etc
                                              % if I want probabilities need to make a matrix of endprobs instead of selecting max
    tm = tm+t;
end


f =maxprob;
