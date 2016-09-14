function v = direction(event, posfile)

% inputs
% posfile (# points, 3)
% even time file (1, times)
% outputs
% vector = [timevector xposvector yposvector fxvector fyvector];


t = posfile(:,1);
x = posfile(:,2);
y = posfile(:,3);

fx = gradient(x);
fy = gradient(y);

% make a matrix of time, x, y, fx, fy
tfxfy = [t x y fx fy];

% go through and find times, assign fx fy values and position

eventsize = size(event,2);
at = size(tfxfy);

timevector = [];
xposvector = [];
yposvector = [];
fxvector = [];
fyvector = [];

i = 1;
newn = 1;
while i <= eventsize
	m = [];
	for n = 1:size(t,1)
		m(end+1) = (abs(event(i)-(t(n))));
		if size(m,2) == 1
			time = tfxfy(n,1);
			xpos = tfxfy(n,2);
			ypos = tfxfy(n,3);
			sfx = tfxfy(n,4);
			sfy = tfxfy(n,5);
			timevector(i) = time;
			xposvector(i) = xpos;
			yposvector(i) = ypos;
			fxvector(i) = sfx;
			fyvector(i) = sfy;
		end

		if size(m,2)>1
			if m(end)<=m(end-1)
				time = tfxfy(n,1);
				xpos = tfxfy(n,2);
				ypos = tfxfy(n,3);
				sfx = tfxfy(n,4);
				sfy = tfxfy(n,5);
				timevector(i) = time;
				xposvector(i) = xpos;
				yposvector(i) = ypos;
				fxvector(i) = sfx;
				fyvector(i) = sfy;
				newn=n;
			end

			if m(end)>m(end-1)
				break
			end
		end	
	end

i=i+1;

end


quiver(xposvector, yposvector, fxvector, fyvector)
v = [timevector; xposvector; yposvector; fxvector; fyvector];




