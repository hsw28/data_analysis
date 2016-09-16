function f = assignvel(timefile, velo);


%takes input of velocity matric from velocity.m
% makes a vector of velocities at every time stamp so you can make a graph against all time points
% smooths data
%
% ex: f = assignvel(tet11.timestamp, velocitymatrix)


tfs = size(timefile,2);
velvector = velo(1,:);
timevector = velo(2,:);
vfs = size(timevector,2);

closestvel=[];

newn=1;
i=1;

tfs;

while i<=tfs
	newn;
	m=[];
	for n = newn:vfs
		m(end+1) = (abs(timefile(i)-(timevector(n))));

		% or use the next line if time data hasn't been divided to seconds
		% m(end+1) = (abs(timefile(i)-(timevector(n)./10000)));
		
		if size(m,2) == 1
			closestv = velvector(n);
			closestvel(i) = closestv;
		end

		if size(m,2)>1
			if m(end)<=m(end-1)
				
				closestv = velvector(n);
				newn=n;
				closestvel(i) = closestv;
			end
			if m(end)>m(end-1)
				break
			end
		end	
	end

i=i+1;

end

f = closestvel;

%smooths with moving average, window 3
%f = smooth(a');			

		
		
		
