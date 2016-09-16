function r = mua_rate(muatimes, start_time, end_time, t);

% finds rate of MUA, outputs as number of spikes per time bin
% function muar = mua_rate(file, start_time, end_time, t);
% MUA must be format [1, evemts]
%
% file should be the loaded file
% t is bin in seconds (for ex, .01 for 10ms)
%
% ex:
% >> [mua.time, mua.rate] = mua_rate(cluster, 455.8529, 24855.7439, 1);
%
% returns a [2, :] matrix of spikes and times

tv = muatimes(:);
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

m = size((time_v),2);
s = 1;
n = 1;
q = 1;

%for the full length of time, go through all the time points and see if they fit in the ms bin
% if they fit, add a tally in the rate vector for that time point

while n <= (m) %for all the times
	while s < (size((tv),1)) %go through the spikes
		if n < m		
			if tv(s) >= time_v(n) && tv(s) < time_v(n+1) %if the spike S is within the time window
				rate(n) = rate(n)+1; %add a tally to the rate vector
				q=s;
			end
		end
		if n == m
			if tv(s) >= time_v(n) && tv(s) <= end_time
				tv(s)
				rate(n) = rate(n)+1;
			end
		end
		s = s+1;
	end
	n=n+1;
	s=q;

end

%output time and rate
r = [rate; time_v];





