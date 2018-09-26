function f = decodeshitPos(time, pos, clusters, tdecode, dim)
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
xbins = ceil((xmax-xmin)/psize) %number of x
ybins = ceil((ymax-ymin)/psize) %number of y


xinc = xmin +(0:xbins-1)*psize; %makes a vectors of all the x values at each increment
yinc = ymin +(0:ybins-1)*psize; %makes a vector of all the y values at each increment


% for each cluster,find the firing rate at esch velocity range
fxmatrix = firingPerPos(pos, clusters, dim);
%outputs a structure of rates

maxprob = [];
spikenum = 1;
times = [];
percents = [];
numcel = [];
maxx = [];
maxy = [];

same = 0;
while tm < (length(timevector)-t)
      %for the cluster, permute through the different conditions
    endprob = zeros(xbins-1, ybins-1);
        for x = (1:xbins-1) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
          for y = (1:ybins-1)
          productme =0;
          expme = 0;
          c = 1;
          occx = find(xvals>=xinc(x) & xvals<xinc(x+1));
          occy = find(yvals>=yinc(y) & yvals<yinc(y+1));
          if length(occx) == 0  & length(occy)==0 %means never went there, dont consider
            endprob(x,y) = NaN;
            break
          end
          while c <= numclust  %permute through cluster
              name = char(clustname(c));
              ni = find(clusters.(name)>=timevector(tm) & clusters.(name)<timevector(tm+t)); % finds index (number) of spikes in range time
              fx = fxmatrix.(name);

              fx = (fx(x, y));
              if fx ~= 0
                productme = productme + length(ni)*log(fx);  %IN
              else
                fx = .00000000000000000000001;
                productme = productme + length(ni)*log(fx);
              end

              expme = (expme) + (fx);
              c = c+1; % goes to next cell, same location

          end
          numcel(end+1) = length(ni);
          % now have all cells at that location
          tmm = t./2000;
        endprob(x, y) = (productme) + (-tmm.*expme); %IN
        end
        end


        endprob = exp(endprob);
        conv = 1./sum(endprob(~isnan(endprob)));
        endprob = endprob.*conv; %matrix of percents
        %percents = vertcat(percents, endprob);
        [maxvalx, maxvaly] = find(endprob == max(endprob(:))); %finds indices
        percents(end+1) = max(endprob(:)); %finds confidence
        if length(maxvalx) > 1 %if probs are the sample, randomly pick one and print warning
            same = same+1;
            maxvalx = datasample(maxvalx, 1);
            maxvaly = datasample(maxvaly, 1);

        end
        maxx(end+1) = (xinc(maxvalx)); %translates to x and y coordinates
        maxy(end+1) = (yinc(maxvaly));
        times(end+1) = timevector(tm);

    tm = tm+t;
    %tm = tm+(t/2); %for overlap?
end

warning('your probabilities were the same')
same = same
values = [maxx; maxy; percents; times];
toc
f = values;
