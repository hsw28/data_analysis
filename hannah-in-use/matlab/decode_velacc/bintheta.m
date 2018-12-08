function f = bintheta(theta, bin, overlap, samplingrate)
%bin in seconds, overlap in seconds
%use to bin theta power or whatever to compare with decoded values

samp = samplingrate;
if overlap>0
overlap = overlap*samp;
else
overlap = bin*samp;
end

binsec = bin;
bin = bin*samp;

k=1;
av = [];
while k<length(theta)-bin
  av(end+1) = mean(theta(k:k+bin));
  k = k+(overlap);
end

f= av;
