function [order spikesinrip] = ripplespikes(ripplematrix, clusters, lag)

%ripple matrix should be [start time, end time] or [start time, peaktime, end time]from findrip.m
%lag is the time after ripple peak you want to look at, IN MS
% spike matrix. matrix should be a matrix where [num of cells, spike times]. can make using padcat

if lag<10 && lag>0
  error('YOU NEED TO ENTER LAG IN MS')
end

lag = lag/1000;

if (size(ripplematrix,1)) == 3
  ripplematrix = [ripplematrix(1,:); ripplematrix(3,:)];
end



clustname = (fieldnames(clusters));
numclust = length(clustname);
maxclust = [];
for c=1:numclust   %permute through cluster

  name = char(clustname(c));
  maxclust(end+1) = length(clusters.(name));
end


for c=1:numclust
  dummy=NaN(max(maxclust),1);
  name = char(clustname(c));
  dummy(1:length(clusters.(name))) = (clusters.(name));
  if c==1
    spikematrix = dummy;
  else
    spikematrix = [spikematrix, dummy];
end
end


if size(spikematrix,1)>size(spikematrix,2)
  spikematrix = spikematrix';
end


ripnum = size(ripplematrix,2);
spikesinrip = zeros(1,ripnum);
order = NaN(ripnum);
biggest = 0;
x = 1;
%figure
%hold on



for k = 1:ripnum

  [cellnum,spikenum,value] = find(spikematrix>=(ripplematrix(1,k)+lag) & spikematrix<(ripplematrix(2,k)+lag));
  allval = horzcat(cellnum, spikenum, value);
  if length(allval)>0
      allval = sort(allval,3);
  else
      %allval = zeros(1,1);
      allval = NaN;

  end

  numripspikes = length(value); %number of spikes in ripple
  spikesinrip(1,k) = numripspikes;
  if numripspikes > biggest
      biggest = numripspikes;
  end

%%%%remove next IF statement if want all sequences (only the if statement not the sutff inside it)

%  if length(allval) == 6
      order(1:length(allval(:,1)), x) = allval(:,1); %think i have to pad to be the same length
      x = x+1;
%
%      plot((0:numripspikes-1)./(numripspikes-1), allval(:,1));
%  end



end


order = order(1:biggest, 1:ripnum);
f = order;

spikesinrip';

%number of spikes per ripple
%f = spikesinrip';

sum(spikesinrip);
