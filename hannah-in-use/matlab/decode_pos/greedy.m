function f = greedy(decodedtimes, decodedarray, posData, dim)
%dim is dimension in cm. should match dimension for decoding

xmin = min(posData(:,2));
ymin = min(posData(:,3));
xmax = max(posData(:,2));
ymax = max(posData(:,3));
xbins = ceil((xmax-xmin)/psize) %number of x
ybins = ceil((ymax-ymin)/psize) %number of y
  timecells = zeros(xbins, ybins); %used to be time
  events = zeros(xbins,ybins);
  xstep = xmax/xbins;
  ystep = ymax/ybins;
  tstep = 1/30;

  xinc = xmin +(0:xbins-1)*psize; %makes a vectors of all the x values at each increment
  yinc = ymin +(0:ybins-1)*psize; %makes a vector of all the y values at each increment

  vel = velocity(posData);
  assvel = assignvelOLD(decodedtimes, vel);

decodedprob = zeros(length(decodedtimes), 1);
decodedx = zeros(length(decodedtimes), 1);
decodedy = zeros(length(decodedtimes), 1);
for k=1:length(decodedtimes)
  currentarray = decodedarray(:,:, k) %make sure it's actually this format
  if assvel(k) > 10 | k == 1 %if animal is moving want chosen position to be closest to animal's position
    [c index] = min(abs(decodedtimes(k)-pos(:,1)));
    currentpos = pos(k, :);
    [c indexx] = min(abs(currentpos(:,2)-xinc)) %closest x value bin
    [c indexy] = min(abs(currentpos(:,2)-yinc)) %closest y value bin
    %for surrounding bins, pick the one with the highest probability
    [maxvalue maxindex] = max(currentarray(indexx-1:indexx+1, indexxy-1:indexxy+1, 1)) %find max probability for surrounding bins
    decodedprob(k) = maxvalue;
    decodedx(k) = currentarray(maxindex(1));
    decodedy(k) = currentarray(maxindex(2));
  else %if animal is stopped, that's when we get greedy based on previous bin location only being consecutive
    %look back at last known position
    previousX = decodedx(k-1);
    previousY = decodedy(k-1);
    [c indexx] = min(abs(previousX-xinc)) %closest x value bin
    [c indexy] = min(abs(previousY-yinc)) %closest y value bin
    [maxvalue maxindex] = max(currentarray(indexx-1:indexx+1, indexxy-1:indexxy+1, 1))
    decodedprob(k) = maxvalue;
    decodedx(k) = currentarray(maxindex(1));
    decodedy(k) = currentarray(maxindex(2));
  end
end



f = [decodedx; decodedy; decodedprob; decodedtimes]
