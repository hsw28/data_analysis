function vectortxy = placeevent(event, pos)

% if you have event times, this will match with place data to get place cells or whatever
% input vector of event times 
% input position file imported from csv in format (data, 3)
% now want to only plot points closest to event/spike/ripple/whatever
%
% outputs a matrix with time, xpos, ypos
%
% ex: 
% txy = placeevent(ripples, position);


eventsize = size(event,2);
alltimes = pos(:,1);

at = size(alltimes);

xposvector = [];
yposvector = [];

i = 1;
newn = 1;
while i <= eventsize
	m = [];
	for n = 1:size(alltimes)
		m(end+1) = (abs(event(i)-(alltimes(n))));
		if size(m,2) == 1
			xpos = pos(n,2);
			ypos = pos(n,3);
			xposvector(i) = xpos;
			yposvector(i) = ypos;
		end

		if size(m,2)>1
			if m(end)<=m(end-1)
				xpos = pos(n,2);
				ypos = pos(n,3);
				xposvector(i) = xpos;
				yposvector(i) = ypos;
				newn=n;
			end

			if m(end)>m(end-1)
				break
			end
		end	
	end

i=i+1;

end

vectortxy = [event; xposvector; yposvector];






