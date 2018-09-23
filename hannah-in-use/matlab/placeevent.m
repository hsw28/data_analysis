function vectortxy = placeevent(event, pos)

% if you have event times, this will match with place data to get place cells or whatever
% input vector of event times
% input position file imported from csv in format (data, 3)
% now want to only plot points closest to event/spike/ripple/whatever
%
% outputs a matrix with time, xpos, ypos
%
% ex:
% txy = placeevent(rippletimes, position);

if size(event,1) <size(event,2)
		event = event';
end

eventsize = length(event);
alltimes = pos(:,1);

at = length(alltimes);

xposvector = [];
yposvector = [];

i = 1;
newn = 1;
while i <= eventsize
	m = [];
	[c index] = min(abs(alltimes-event(i)));
	index = index(1);
	xpos = pos(index,2);
	ypos = pos(index,3);
	xposvector(i) = xpos;
	yposvector(i) = ypos;

	i=i+1;
end


vectortxy = [event'; xposvector; yposvector];


% DEPRECATED AND SHITTY
%
%	for n = 1:size(alltimes)
%		m(end+1) = (abs(event(i)-(alltimes(n))));
%		if size(m,2) == 1
%			xpos = pos(n,2);
%			ypos = pos(n,3);
%			xposvector(i) = xpos;
%			yposvector(i) = ypos;
%		end
%
%		if size(m,2)>1
%			if m(end)<=m(end-1)
%				xpos = pos(n,2);
%				ypos = pos(n,3);
%				xposvector(i) = xpos;
%				yposvector(i) = ypos;
%				newn=n;
%			end
%
%			if m(end)>m(end-1)
%				break
%			end
%		end
%	end
