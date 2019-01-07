function f = posdistro(posXYnotime)

comparething = posXYnotime;

if size(comparething, 1) > size(comparething, 2)
  comparething = comparething';
end

x = comparething(1,:);
y = comparething(2,:);

statecount = [];
for k=1:length(x)
  if x(k)< 517 & y(k)>=557
    statecount(end+1) = 1;
  %2
  elseif x(k)< 517 &  y(k)>= 410 & y(k)< 557
    statecount(end+1) = 2;
  %3
elseif x(k) < 517 & y(k) < 353 & y(k) >= 165
    statecount(end+1) = 3;
  %4
elseif x(k)< 517 & y(k) < 165 %165 for reg, 183 for decoded??
    statecount(end+1) = 4;
  %7
elseif x(k) >= 797 & y(k)>=586
    statecount(end+1) = 7;
  %8
elseif x(k) >=797  & y(k)< 586 & y(k)> 428
    statecount(end+1) = 8;
  %9
elseif x(k) >=797  & y(k)>=180  & y(k)< 387 % 180 if reg pos, 131 if decode
    statecount(end+1) = 9;
  %10
elseif x(k) >=797 & y(k)< 180 %180 if reg pos, 131 if decode
    statecount(end+1) = 10;
    %5
  elseif x(k)< 662
    statecount(end+1) = 5;
    %6
  elseif x(k)>=662
    statecount(end+1) = 6;
  else
    statecount(end+1) = NaN;
  end
end

f = statecount;

%figure
%histogram(statecount)
[n,x] = hist(statecount);
barstrings = num2str(n');
text(x,n,barstrings,'horizontalalignment','center','verticalalignment','bottom');
