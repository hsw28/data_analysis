function f = assignvelOLD(timefile, velo);


%takes input of velocity matric from velocity.m
% makes a vector of velocities at every time stamp so you can make a graph against all time points
% smooths data
%
% ex: f = assignvel(tet11.timestamp, velocitymatrix)


velvector = velo(1,:);
timevector = velo(2,:);
f = timevector;
closestvel=[];

i=1;


index = 1;
while i<=length(timefile)
		%newvec = timevector(index:end);
		[m index] = min(abs(timefile(i)-timevector));
		closestvel(i) = velvector(index);
		i=i+1;


end

f = closestvel;
