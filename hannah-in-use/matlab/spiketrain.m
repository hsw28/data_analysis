function x = spiketrain(spike, tm, binwidth);

% makes a spike train where 0 is no spike, 1 is a spike
% input spike times and session times
% can insert a matrix of spike data
%
% ex: spiketrain(spiketime, lfp.timestamp);

[c indexmin] = (min(abs(spike-tm(1))));
[c indexmax] = (min(abs(spike-tm(end))));
spike = spike(indexmin:indexmax);


%making sure no spikes fall outside of time
[c index] = min(abs(spike-tm(1)));
if tm(1)-c < 0 % then closest value is before start time
		spike = spike(index+1:end);
else
		spike = spike(index:end);
end
[c index] = min(abs(spike-tm(end)));
if tm(end)-c < 0 %then closest value is after start time
		spike = spike(1:index-1);
else
		spike = spike(1:index);
end


spike;
x = histcounts(spike, [tm(1):binwidth:tm(end)])';
