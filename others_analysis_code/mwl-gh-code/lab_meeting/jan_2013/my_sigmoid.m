function y = my_sigmoid(x,start,stop)
slope = 1/(stop - start) * 10;
y = 1 ./ (1 + exp(-((x-start).*slope -5)));