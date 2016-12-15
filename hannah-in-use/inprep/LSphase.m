function f = LSphase(firingtimes, lfp)

%input lfp, cell firing

%finds theta peak closest peak to cell firing for LS LFP
% plots histogram

peaktimes = thetaphaseLS(lfp);
distance = [];

i = 1;
size(firingtimes);
while i<= size(firingtimes,1)
	
	x = find( abs(peaktimes-firingtimes(i)) < .17 & abs(peaktimes-firingtimes(i)) > .08);
		if size(x,1) == 0
			i = i+1;
		elseif size(x,1) == 1

			distance(end+1) = x(1) - firingtimes(i);
			i = i+1;
		elseif size(x,1) > 1
			closest = min(abs(x-firingtimes(i)));
			distance(end+1) = closest;
			i = i+1;
		end
end

f = figure;
histogram(distance, 36)
