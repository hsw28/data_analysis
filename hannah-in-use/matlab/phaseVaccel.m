function f = phaseVaccel(spikephase, acc, minacc)

%plots spike phase versus acceleration for all acceleration values over inputted min
%input phase data from firingphase function

assacc = assignvel(spikephase(2,:), acc);

newass = [];
newphase = [];
i = 1;
while i <= size(assacc,2)
	if abs(assacc(1,i)) > minacc
		newass(end+1) = (assacc(i));
		newphase(end+1) = spikephase(1,i);
	end
i=i+1;
end


f = [newass; newphase];
scatter(newass, newphase)
