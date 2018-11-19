function f = ripplespikes(ripplematrix, spikematrix)

%ripple matrix should be [start time, end time] from findrip.m
% spike matrix. matrix should be a matrix where [num of cells, spike times]. can make using padcat

%clustname = (fieldnames(clusters));
%numclust = length(clustname);
%spikematrix = [];
%for c=1:numclust   %permute through cluster
%  name = char(clustname(c));
%  spikematrix = padcat(spikematrix, clusters.(name));
%nd


ripnum = length(ripplematrix);
spikesinrip = zeros(1,ripnum);
order = NaN(ripnum);
biggest = 0;
x = 1;
%figure
%hold on

for k = 1:ripnum
  [cellnum,spikenum,value] = find(spikematrix>= ripplematrix(1,k) & spikematrix<ripplematrix(2,k));
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
%biggest
%order = order(1:biggest, 1:x-1);
order = order(1:biggest, 1:ripnum);
f = order;

%number of spikes per ripple
%f = spikesinrip';
