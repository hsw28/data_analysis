function f = bintheta(theta, bin, overlap)
%bin in seconds, overlap in seconds
%use to bin theta power or whatever to compare with decoded values

overlap = bin/overlap
binsec = bin;
bin = bin*2000;

k=1;
av = [];
while k<length(theta)-bin
  av(end+1) = mean(theta(k:k+bin));
    k = k+bin/overlap;
end

f= av;
