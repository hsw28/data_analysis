function [times matrices maxes] = decodeshitPosBIG(time, pos, clusters, tdecode, dim)
%decodes position and outputs decoded x, y, confidence(in percents), and time. if you want to filter spiking for veloctity you put velocity in varargin
tic
posData = pos;
timevector = time;

t = tdecode;
t = 2000*t;
tm = 1;

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);

%BIN
psize = 3.5 * dim;

xvals = posData(:,2);
yvals = posData(:,3);
xmin = min(posData(:,2));
ymin = min(posData(:,3));
xmax = max(posData(:,2));
ymax = max(posData(:,3));
xbins = ceil((xmax-xmin)/psize); %number of x
ybins = ceil((ymax-ymin)/psize); %number of y


xinc = xmin +(0:xbins)*psize; %makes a vectors of all the x values at each increment
yinc = ymin +(0:ybins)*psize; %makes a vector of all the y values at each increment


% for each cluster,find the firing rate at esch velocity range
fxmatrix = firingPerPos(pos, clusters, dim)
%outputs a structure of rates

maxprob = [];
spikenum = 1;
times = [];
percents = [];
numcel = [];
maxx = [];
maxy = [];
matrices = zeros(xbins, ybins, ceil(length(timevector)/t)-1);
same = 0;
num = 1;

while tm < (length(timevector)-t)
      %for the cluster, permute through the different conditions
      endprob = zeros(xbins, ybins);
        for x = (1:xbins) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
          for y = (1:ybins)
          productme =0;
          expme = 0;
          c = 1;

          if x<xbins & y<ybins
            occx = find(xvals>=xinc(x) & xvals<xinc(x+1));
            occy = find(yvals>=yinc(y) & yvals<yinc(y+1));
          elseif x==xbins & y<ybins
            occx = find(xvals>=xinc(x));
            occy = find(yvals>=yinc(y) & yvals<yinc(y+1));
          elseif x<xbins & y==ybins
            occx = find(xvals>=xinc(x) & xvals<xinc(x+1));
            occy = find(yvals>=yinc(y));
          elseif x==xbins & y==ybins
            occx = find(xvals>=xinc(x));
            occy = find(yvals>=yinc(y));
          end


          if length(occx) == 0  & length(occy)==0 %means never went there, dont consider
            endprob(x,y) = NaN;
            break
          end
          while c <= numclust  %permute through cluster
              name = char(clustname(c));
              %ni = find(clusters.(name)>=timevector(tm) & clusters.(name)<timevector(tm+t)); % finds index (number) of spikes in range time
              ni = length(clusters.(name)(clusters.(name)>=timevector(tm) & clusters.(name)<timevector(tm+t)));
              fx = fxmatrix.(name);

              fx = (fx(x, y));
              if fx ~= 0
                productme = productme + (ni)*log(fx);  %IN
              else
                fx = .00000000000000000000001;
                productme = productme + (ni)*log(fx);
              end

              expme = (expme) + (fx);
              c = c+1; % goes to next cell, same location

          end
          numcel(end+1) = (ni);
          % now have all cells at that location
          tmm = t./2000;
        endprob(x, y) = (productme) + (-tmm.*expme); %IN
        end
        end

                endprob = exp(endprob);
                conv = 1./sum(endprob(~isnan(endprob)));
                endprob = endprob.*conv; %matrix of percents

                matrices(:,:,num) = endprob;

                [maxvalx, maxvaly] = find(endprob == max(endprob(:))); %finds indices
                percents(end+1) = max(endprob(:)); %finds confidence
                if length(maxvalx) > 1 %if probs are the sample, randomly pick one and print warning

                    maxvalx = datasample(maxvalx,1 );
                    maxvaly = datasample(maxvaly,1);

                end

                if isempty(maxvalx)==1 | isempty(maxvaly) ==1
                  maxx(end+1) = 0;
                  maxy(end+1) =0;
                  fprintf('you have a zero matrix')
                else
                    if max(endprob(:))==0
                      maxx(end+1) = NaN;
                      maxy(end+1) = NaN;
                    else
                      maxx(end+1) = (xinc(maxvalx)); %translates to x and y coordinates
                      maxy(end+1) = (yinc(maxvaly));
                    end
                end

        times(end+1) = timevector(tm);

        if tdecode>=.25
          tm = tm+(t/2);
        else
          tm = tm+t;
        end
num = num+1

end

toc
times = times;
matrices = matrices;
maxx = maxx+psize/2;
maxy = maxy+psize/2;
maxes = [maxx; maxy; percents; times];
