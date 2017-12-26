function r = mua_rate_points(cluster, time, t)
% DOES IT IN NUMBER OF SAMPLES INSTEAD OF TIME
% finds rate of MUA, outputs as number of spikes per time bin
% function muar = mua_rate(file, start_time, end_time, t);
% MUA must be format [1, evemts]
%
% file should be the loaded file
% t is bin in seconds (for ex, .01 for 10ms or 1 for 1 second)
%
% ex:
% >> [mua.time, mua.rate] = mua_rate(cluster, 455.8529, 24855.7439, 1);
%
% returns a [2, :] matrix of spikes and times

%going through all the time and making a vector time_v with each millisecond

t = t*2000;
bins = ceil(length(time)./t)-1
mua = [];
timev = [];
for k = 1:bins
    if k==1
      findit = find(cluster>=time(k) & cluster<=time(k*t));
      mua(end+1) = length(findit);
    else
      findit = find(cluster>time((k-1)*t) & cluster<=time(k*t));
      mua(end+1) = length(findit);
      
    end

end


r = mua;
