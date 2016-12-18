function f = compareISI(spiketimes, comparething);

if size(comparething,1)>size(comparething,2)
	comparething = comparething';
end

% compare theta phase or power or acc to ISI

[isidata, index] = isi(spiketimes);

isidata = [isidata(1:end-1), spiketimes(2:end)];

%now isi data contains the ISI and the time


isidata = isidata';
i = 1;
isinew = [];
isitime = [];
data = isidata(1,:);
data=data';
while i<=size(data,1)
	if data(i) < .17
		isinew(end+1) = isidata(1,i);
		isitime(end+1) = isidata(2,i);
	end
i=i+1;
end

isidata = [isinew; isitime];


size(isidata);
compare = assignvel(isidata(2,:), comparething);

size(compare);
scatter(isidata(1,:), compare(1,:))

