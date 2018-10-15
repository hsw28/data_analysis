function f = bintheta(theta, bin)
%bin in seconds
%use to bin theta power or whatever to compare with decoded values

binsec = bin;
bin = bin*2000;

k=1;
av = [];
while k<length(theta)-bin
  av(end+1) = mean(theta(k:k+bin));
  if binsec >= .25
    k = k+bin/2;
  else
    k = k+bin;
  end
end

f= av;
