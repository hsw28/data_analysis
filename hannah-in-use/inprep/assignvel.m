function f = assignvel(timefile, velo);

%takes input of velocity matric from velocity.m
% makes a vector of velocities at every time stamp so you can make a graph
% ex:
% f = assignvel(tet11.timestamp, velocitymatrix)


tfs = size(timefile,2);
velvector = velo(1,:);
timevector = velo(2,:);
vfs = size(timevector,2);

closestvel=[];

for i = 1:tfs
	m = [];
	for n = 1:vfs
		m(end+1) = (abs(timefile(i)-timevector(n)));
		
		if size(m,2) == 1
			closestv = velvector(n);
		end

		if size(m,2)>1
			if m(end)>=m(end-1)
				closestv = velvector(n);
			end
		end

		if m<=.005
			break
		end
			
	end
closestvel(i) = closestv;

end

f = closestv;

			
		
		
		
