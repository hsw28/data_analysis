function f = wheelVEL(degree)
%input degree data, get velocity in degrees/sec as output

wrapped = wheelwrap(degree);


velvector = [];
timevector = [];

time = wrapped(:,1);
deg = wrapped(:,2);
s = length(time);

deg = hampel(deg, 400);
deg = smooth(deg, 400);

i = 501;
while i <= s - 500
	%find distance travelled
	if time(i)~=time(i-500)

		vel = (deg(i+500)-deg(i-500))/((time(i+500)-time(i-500)));
		velvector(end+1) = abs(vel);
		timevector(end+1) = time(i);
	end
  i = i+1;
end

v = (velvector);
v = (wthresh(velvector, 's', 50));
f = [v; timevector];
