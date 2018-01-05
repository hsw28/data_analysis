function x = spiketrain(spike, tm);

% makes a spike train where 0 is no spike, 1 is a spike
% input spike times and session times
% can insert a matrix of spike data
%
% ex: spiketrain(spiketime, lfp.timestamp);

if size(spike,1) < size(spike,2)
	spike = spike';
end
if size(tm, 1) > size(tm,2)
	tm = tm';
end

x = hist(spike, tm)';
