function muar = mua_rate(file, start_time, end_time, t);

% finds rate of MUA
% function muar = mua_rate(file, start_time, end_time, t);
%
% file should be the loaded file
% t is bin in seconds (for ex, .01 for 10ms)
%
% ex:
% r = mua_rate(maze_cl_2, 455.8529, 24855.7439, .01);

tv = file(:,8);
%make a vector of firing times

ms_time = (end_time-start_time);
time_v = [];

k = start_time;
%going through all the time and making a vector time_v with each millisecond
while k <= end_time
	time_v(end+1) = k;
	k = k+t;
	%k = k+1;
end


%make empty rate vector
rate = zeros(size(time_v));

m = size((time_v),2)
s = 1;
q = 1;

%for the full length of time, go through all the time points and see if they fit in the ms bin
% if they fit, add a tally in the rate vector for that time point
for n = 1:(m-1)
	r = 0;
	while s <= (size((tv),1))
		if tv(s) >= time_v(n) && tv(s) < time_v(n+1)
			rate(n) = rate(n)+1;
			q = s;
		end
		s = s+1;
	end
	s = q;
end

muar = rate;
			
	
	



