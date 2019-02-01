function f = shufflevel(vel, seconds_in_group)

numingroup = seconds_in_group*30

numcolumn = numingroup; %this is seconds across (so 15 for .5 seconds)
numrows = floor(length(vel(1,:))./numingroup);


f = reshape(vel(1,1:numrows*numcolumn), [numcolumn, numrows]);

f = f(:, randperm(numrows));
f = reshape(f, [1, numrows*numcolumn]);
f = vertcat(f, vel(2,1:length(f)));
