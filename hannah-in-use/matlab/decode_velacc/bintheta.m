function f = bintheta(theta, bin, overlap)
%bin in seconds, overlap in seconds
%use to bin theta power or whatever to compare with decoded values

if overlap>0
overlap = overlap*2000;
else
overlap = bin*bin*2000*2000;
end

binsec = bin;
bin = bin*2000;

k=1;
av = [];
while k<length(theta)-bin
  av(end+1) = mean(theta(k:k+bin));
  k = k+round(overlap/bin);
end

f= av;
