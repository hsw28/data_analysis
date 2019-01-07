function [fvalues fmatrix] = decodeshitPosQuad(time, pos, clusters, tdecode)

%instead of decoding in a grid, decodes different quadrants of space

posData = pos;
timevector = time;

t = tdecode;
t = 2000*t;
tm = 1;

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);


xvals = posData(:,2);
yvals = posData(:,3);
xmin = min(posData(:,2));
ymin = min(posData(:,3));
xmax = max(posData(:,2));
ymax = max(posData(:,3));


%position 1: end of left forced
%position 2: left forced
%position 3: forced choice point
%position 4: right forced
%position 5: end of right forced
%position 6: middle stem
%position 7: end of left choice
%position 8 left choice arm
%position 9: free choice point
%position 10: right choice arm
%position 11: end of right choice arm

%defiding position
      %   [ 1   2   3   4   5   6   7   8   9   10 ]
%xlimmin = [320 320 320 320 420 750 780 835 780 780];
%xlimmax = [505 420 420 505 835 950 950 950 950 950];
%ylimmin = [548 360 160 000 300 556 415 334 187 000];
%ylimmax = [700 548 360 160 440 700 556 415 334 187];

%TRIED AND TRUE
%          [ 1   2   3   4   5   6   7   8   9   10 ]

         %[ 1   2   3   4   5   6   7   8   9   10 ]
xlimmin = [320 320 320 320 320 440 750 780 828 780 780];
xlimmax = [505 450 440 505 505 828 950 950 950 950 950];
ylimmin = [545 422 320 170 000 300 575 420 339 182 000];
ylimmax = [700 545 422 320 170 440 700 575 420 339 182];



% for each cluster,find the firing rate at esch velocity range
fxmatrix = firingPerPosQuad(pos, clusters, tdecode);
%outputs a structure of rates

maxprob = [];
spikenum = 1;
times = [];
percents = [];
numcel = [];
maxquad = [];
same = 0;
mat = zeros(length(xlimmin), 1);
n =01
nivector = zeros((numclust),1);


while tm < (length(timevector)-t)
   %find spikes in each cluster for time
   for c=1:numclust   %permute through cluster
     name = char(clustname(c));
     nivector(c) = length(clusters.(name)(clusters.(name)>=timevector(tm) & clusters.(name)<timevector(tm+t)));
   end

      %for the cluster, permute through the different conditions
    endprob = zeros(length(xlimmin),1);

        for k = (1:length(xlimmin))  %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
          %for y = (1:ybins)
          productme =0;
          expme = 0;
          occx = find(xvals > xlimmin(k) & xvals<=xlimmax(k));
          occy = find(yvals > ylimmin(k) & yvals<=ylimmax(k));
          if length(occx) == 0  & length(occy)==0 %means never went there, dont consider
            endprob(k) = NaN;
            break
          end

          for c=1:numclust  %permute through cluster
              ni = nivector(c);
              name = char(clustname(c));
              fx = fxmatrix.(name);
              fx = (fx(k));
              productme = productme + (ni)*log(fx);  %IN
              expme = (expme) + (fx);
               % goes to next cell, same location
          end


          % now have all cells at that location
          tmm = t./2000;
        endprob(k) = (productme) + (-tmm.*expme); %IN
        end




      mquad = find(endprob == max(endprob(:)));
      mp = max(endprob)-12;

    endprob = exp(endprob-mp);


        conv = 1./sum(endprob(~isnan(endprob)), 'all');
        endprob = endprob.*conv; %matrix of percents
        mat(:, end+1) = endprob;

        %percents = vertcat(percents, endprob);
        %mquad = find(endprob == max(endprob(:))); %finds indices of max prob
        percents(end+1) = max(endprob(:)); %finds confidence

        if length(mquad) > 1 %if probs are the sample, randomly pick one and print warning
            same = same+1;
            mquad = datasample(mquad, 1);
        end



            if length(mquad)<1
              maxquad(end+1) = NaN;
            else
              maxquad(end+1) = (mquad); %translates to x and y coordinates
            end



        times(end+1) = timevector(tm);


    %if tdecode>=.25
    %  tm = tm+(t/2);
    %else
      tm = tm+t;
    %end
    %tm = tm+(t/2); %for overlap?
    n = n+1;
end

warning('your probabilities were the same')
same = same
values = [maxquad; percents; times];

fvalues = values;
fmatrix = mat;
