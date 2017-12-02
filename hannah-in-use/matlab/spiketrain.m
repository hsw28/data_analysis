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

train = zeros(size(tm));
alltrain = [];
size(spike);
for f=size(spike,2)
		onespike = spike(:,f);
		train = train';
		k=[];

		i = 1;
		while i<=size(onespike,1)
			k = find(abs(tm-onespike(i))<.0001, 1);
			train(k) = train(k)+1;
			i = i+1;
		end
alltrain = [alltrain; train];
end

x = alltrain;
