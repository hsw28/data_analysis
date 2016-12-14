function fuckme = binning(x, y);

%input data in x and number of points you want per bin in y


binned = [];
n = 1;
while n <= size(x,1)
	n;
	if n+y-1 <= size(x,1)
		binned(end+1) = sum(x(n:n+y-1));
	else
		binned(end+1) = sum(x(n:end));
	end
	n = n+y;
end

fuckme = binned;
