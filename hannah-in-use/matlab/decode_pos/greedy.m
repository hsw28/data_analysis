function f = greedy(decodedtimes, decodedarray, posData, dim)
%dim is dimension in cm. should match dimension for decoding

tic
psize = 3.5 * dim; %some REAL ratio of pixels to cm
xmin = min(posData(:,2));
ymin = min(posData(:,3));
xmax = max(posData(:,2));
ymax = max(posData(:,3));
xbins = ceil((xmax-xmin)/psize); %number of x
ybins = ceil((ymax-ymin)/psize); %number of y
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
rank = zeros(length(decodedtimes), 1);

for k=1:size(decodedarray, 3)

  currentarray = decodedarray(:,:, k);


  if assvel(k) > 12 | k == 1 %if animal is moving want chosen position to be closest to animal's position
    [c index] = min(abs(decodedtimes(k)-posData(:,1)));
    currentpos = posData(index, :);
    possiblesX = xinc <= currentpos(:,2);
    possiblesY = yinc <= currentpos(:,3);
    [c indexx] = min(abs(currentpos(:,2)-xinc(possiblesX))); %closest x value bin
    [c indexy] = min(abs(currentpos(:,3)-yinc(possiblesY))); %closest y value bin
    %for surrounding bins, pick the one with the highest probability

      xlessthan=min(2, indexx-1);
      xmorethan=min(abs(indexx-length(xinc))-1, 2);
      ylessthan=min(2, indexy-1);
      ymorethan=min(abs(indexy-length(yinc))-1, 2);
      confinedarray = currentarray(indexx-xlessthan:indexx+xmorethan, indexy-ylessthan:indexy+ymorethan, 1);
      %find max probability for surrounding bins
      maxvalue = max(confinedarray(:));

      %[maxX maxY] = find(currentarray(indexx-xlessthan:indexx+xmorethan, indexy-ylessthan:indexy+ymorethan) == maxvalue)
      [maxX maxY] = find(currentarray == maxvalue);
      if length(maxX>1) | length(maxY>1)
        correctX = find(maxX>=indexx-xlessthan & maxX<=indexx+xmorethan);
        correctY = find(maxY>=indexy-ylessthan & maxY<=indexy+ymorethan);
        maxX = maxX(correctX);
        maxY = maxY(correctY);
      end

    decodedprob(k) = maxvalue;
    decodedx(k) = xinc(maxX(1));
    decodedy(k) = yinc(maxY(1));
    linearrank = reshape(currentarray,[size(currentarray,1)*size(currentarray,2), 1]);
    linearrank = sort(linearrank(~isnan(linearrank)), 'descend');
    linearrank = find(linearrank==maxvalue);
    rank(k) = linearrank(1);
else %if animal is stopped, that's when we get greedy based on previous bin location only being consecutive
    %either want consistant with last known bin OR at current location

    %look back at last known position

    previousX = decodedx(k-1);
    previousY = decodedy(k-1);
    indexx = find(xinc==previousX); %closest x value bin
    indexy = find(yinc==previousY); %closest y value bin

    xlessthan=min(2, indexx-1);
    xmorethan=min(abs(indexx-length(xinc))-1, 2);
    ylessthan=min(2, indexy-1);
    ymorethan=min(abs(indexy-length(yinc))-1, 2);

    confinedarraypast = currentarray(indexx-xlessthan:indexx+xmorethan, indexy-ylessthan:indexy+ymorethan, 1);
    maxvaluepast = max(confinedarraypast(:)); %this is the max probability for around previous location
    %[maxX maxY] = find(currentarray(indexx-xlessthan:indexx+xmorethan, indexy-ylessthan:indexy+ymorethan, 1) == maxvalue)

    %% now we will find it for current location
    [c index] = min(abs(decodedtimes(k)-posData(:,1)));
    currentpos = posData(index, :);
    possiblesX = xinc <= currentpos(:,2);
    possiblesY = yinc <= currentpos(:,3);
    [c indexxcurrent] = min(abs(currentpos(:,2)-xinc(possiblesX))); %closest x value bin
    [c indexycurrent] = min(abs(currentpos(:,3)-yinc(possiblesY))); %closest y value bin
    xlessthancurrent=min(2, indexxcurrent-1);
    xmorethancurrent=min(abs(indexxcurrent-length(xinc))-1, 2);
    ylessthancurrent=min(2, indexycurrent-1);
    ymorethancurrent=min(abs(indexycurrent-length(yinc))-1, 2);
    confinedarray = currentarray(indexxcurrent-xlessthancurrent:indexxcurrent+xmorethancurrent, indexycurrent-ylessthancurrent:indexycurrent+ymorethancurrent);
    maxvaluecurrent = max(confinedarray(:));


    if maxvaluepast > maxvaluecurrent
      maxvalue = maxvaluepast;
      [maxX maxY] = find(currentarray == maxvalue);
      if length(maxX>1) | length(maxY>1)
        correctX = find(maxX>=indexx-xlessthan & maxX<=indexx+xmorethan);
        correctY = find(maxY>=indexy-ylessthan & maxY<=indexy+ymorethan);
        maxX = maxX(correctX);
        maxY = maxY(correctY);
      end
    else
      maxvalue = maxvaluecurrent;
      [maxX maxY] = find(currentarray == maxvalue);
      if length(maxX>1) | length(maxY>1)
        correctX = find(maxX>=indexxcurrent-xlessthancurrent & maxX<=indexxcurrent+xmorethancurrent);
        correctY = find(maxY>=indexycurrent-ylessthancurrent & maxY<=indexycurrent+ymorethancurrent);
        maxX = maxX(correctX);
        maxY = maxY(correctY);
      end
    end



    decodedprob(k) = maxvalue;
    decodedx(k) = xinc(maxX(1));
    decodedy(k) = yinc(maxY(1));
    linearrank = reshape(currentarray,[size(currentarray,1)*size(currentarray,2), 1]);


    linearrank = sort(linearrank(~isnan(linearrank)), 'descend');
    linearrank = find(linearrank==maxvalue);
    rank(k) = linearrank(1);
  end
  k;
end


toc

f = [decodedx'; decodedy'; decodedprob'; decodedtimes; rank'; assvel];
f = f';
