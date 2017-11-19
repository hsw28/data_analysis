
Y = poisspdf(n,lambda)

% define a time window, see how often cells spike during that time window
% based on average firing rate at different velocities, estimate velocity



%DEFINE TIME WINDOW

%WANT TO PERMUTE THROUGH ALL I'S WHERE I IS THE CELL number
i = 1;
while i < % total number of cells
  % spikesintime = find spikes in time window
  spikesinwin = find %time stamps of cells that fit within window
  n = size %to get number of spikes DONE

  %now just need to get lambda
  %PERMUTE THROUGH ALL THE VELOCITY RANGES
  v = 0;
  % set velocity ranges
  while v % is in between first range

      %lambda = t*fi(x) where fi(x) is the average firing rate of cell i at velocity x
      % want to bin velocity, determine all cells firing rates at each binned velocity
      % plug in for each cell
      lambda = time window * average firing rate of cell at your velocity
      % find firing rate for each velocity 

      % the output of accelVsFiringRate is a matrix (firing rate, )
