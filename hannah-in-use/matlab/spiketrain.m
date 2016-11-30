function x = spiketrain(spike, tm);

% makes a spike train where 0 is no spike, 1 is a spike
% input spike times and session times
%
% ex: spiketrain(spiketime, lfp.timestamp);

if size(spike,1) < size(spike,2)
	spike = spike';
end
if size(tm, 1) > size(tm,2)
	tm = tm';
end

train = zeros(size(tm));

train = train';
k=[];

i = 1;
while i<=size(spike,1)
	k = find(abs(tm-spike(i))<.0001, 1);
	train(k) = train(k)+1;
	i = i+1;
end

x = train;


