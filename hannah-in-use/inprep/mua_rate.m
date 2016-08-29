function muar = mua_rate(file, start_time, end_time);

%make a vector of firing times
tv = file(:,8);

ms_time = (end_time-start_time);
time_v = [];

k = start_time;
%going through all the time and making a vector time_v with each millisecond
while k <= end_time
	time_v(end+1) = k;
	%k = k+.001;
	k = k+1;
end


%make empty rate vector
rate = zeros(size(time_v));

m = size((time_v),2)

%for the full length of time, go through all the time points and see if they fit in the ms bin
% if they fit, add a tally in the rate vector for that time point
for n = 1:(m-1)
	r = 0;
	for s = 1:(size((tv),1))
		s;
		tv(s);
		time_v(n);
		time_v(n+1);
		if tv(s) >= time_v(n) && tv(s) < time_v(n+1)
			rate(n) = rate(n)+1;
		end
	end
end

muar = rate;
			
	
	



