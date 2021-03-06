function x = spikehisto(spike, tm, bins);



% makes a vector of  the number of spikes per bin
% input spike times and session times
%
% ex: spiketrain(spiketime, lfp.timestamp, bins);
% bin argument is in ms. if no binning then it is per time stamp


if size(spike,1) < size(spike,2)
	spike = spike';
end
if size(tm, 1) > size(tm,2)
	tm = tm';
end

% since sampling at 2000hz each time stamp is .5ms so need to figure out num of timestamps
numts=bins/.5;
%train = zeros(ceil(size(tm)/numts));
%train = train';
train = [];
sz = (ceil(length(tm)/numts));
k=[];

x= histcounts(spike, sz);
%i = 1;
%while i<=(sz)
%	if i == 1
%	k = find(spike>(tm((i))) &  spike<(tm((i*numts))));
%	train(end+1) = length(k);
%  elseif i > 1 && i<(sz)
%	k = find(spike>(tm((i-1)*numts)) &  spike<(tm((i*numts))));
%	train(end+1) = length(k);
%  elseif i == (sz);
%	k = find(spike>(tm((i-1)*numts)) &  spike<(tm((end))));
%	train(end+1) = length(k);
%	end
%	i = i+1;
%end

%x = train;
%xax = (1:bins/1000:(length(x)./bins*10));
%while length(xax) < length(x)
%			xax(end+1) = length(xax)+1;
%
%	end
%
%xax = xax';

%bar((1:length(x))/(bins/10), x, 'barwidth', 1)
