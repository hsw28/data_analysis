function [f allsizescenters] = MASSplacefieldnum_resid(clusters,posstructure, dim)

      set(0,'DefaultFigureVisible', 'off');

%determine how many spikes & pos files

allsizes = [];
allcenterXmean = [];
allcenterYmean = [];
allcenterXmax = [];
allcenterYmax = [];
allskew = [];
clustspikenames = (fieldnames(clusters));
spikenum = length(clustspikenames);

posnames = (fieldnames(posstructure));
posnum = length(posnames);
pnames = {};
for s = 1:posnum
  if contains(posnames(s), 'position')==1
    pnames(end+1) = (posnames(s));
  end
end

output = {'cluster name'; 'cluster size'; 'num of fields'; 'field size in cm'; 'centermax'; 'centermean'};

for z = 1:length(pnames)
  currentname = char(pnames(z))
  posData = posstructure.(currentname);
  posData = fixpos(posData);
  % get date of spike
  date = strsplit(currentname,'date_'); %splitting at year rat12_2018_08_20_time
  date = char(date(1,2));
  date = strsplit(date,'_position'); %rat12_2018_08_20
  date = char(date(1,1));

  %Sum of (occprobs * mean firing rate per bin / overall mean rate) * log2 (mean firing rate per bin / overall mean rate)


  cnames = {};

  cstart = 0;
  cend = 100000000;

  currentclusts = struct;
  for c = 1:(spikenum)
    name = char(clustspikenames(c));
    date;
    if contains(name, date)==1 & cstart==0
      [currentclusts(:).(name)] = deal(clusters.(name));
    end
  end

  currentclustname = (fieldnames(currentclusts));
  currentnumclust = length(currentclustname);


  if currentnumclust>0
  acc = accel(posData);
  vel = velocity(posData);
  acc = accel(posData);

velthreshold = 12;
  vel = velocity(posData);
  vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
  fastvel = find(vel(1,:) > velthreshold);
  totaltime = length(fastvel)./30;
  posDataFast = posData(fastvel, :);
  xvalsFast = posDataFast(:,2);
  yvalsFast = posDataFast(:,3);

  psize = 3.5 * dim;
  xvals = posDataFast(:,2);
  yvals = posDataFast(:,3);
  xmin = min(posDataFast(:,2));
  ymin = min(posDataFast(:,3));
  xmax = max(posDataFast(:,2));
  ymax = max(posDataFast(:,3));
  xbins = ceil((xmax)/psize); %number of x
  ybins = ceil((ymax)/psize); %number of y
  xinc = (0:xbins)*psize; %makes a vectors of all the x values at each increment
  yinc = (0:ybins)*psize; %makes a vector of all the y values at each increment

  %occupancy
  occ = zeros(xbins, ybins);
  testing = 0;
  for x = (1:xbins)
    for y = (1:ybins)
      if x<xbins & y<ybins
      occx = find(xvalsFast>=xinc(x) & xvalsFast<xinc(x+1));
      occy = find(yvalsFast>=yinc(y) & yvalsFast<yinc(y+1));
      elseif x==xbins & y<ybins
      occx = find(xvalsFast>=xinc(x));
      occy = find(yvalsFast>=yinc(y) & yvalsFast<yinc(y+1));
      elseif x<xbins & y==ybins
      occx = find(xvalsFast>=xinc(x) & xvalsFast<xinc(x+1));
      occy = find(yvalsFast>=yinc(y));
      elseif x==xbins & y==ybins
      occx = find(xvalsFast>=xinc(x));
      occy = find(yvalsFast>=yinc(y));
      end

      if length(intersect(occx, occy)) == 0
      occ(x,y) = NaN;
      else
      occ(x,y) = length(intersect(occx, occy));
      end
  end
  end

numocc = occ(~isnan(occ));
occtotal = sum(((numocc)), 'all');
occprobs = occ./(occtotal);

%Sum of (occprobs * mean firing rate per bin / meanrate) * log2 (mean firing rate per bin / meanrate)

%spike rates
cnames = {};

cstart = 0;
cend = 100000000;

currentclusts = struct;
for c = 1:(spikenum)
  name = char(clustspikenames(c));
  date;
  if contains(name, date)==1 & cstart==0
    [currentclusts(:).(name)] = deal(clusters.(name));
  end
end

currentclustname = (fieldnames(currentclusts));
currentnumclust = length(currentclustname);



for c = 1:(currentnumclust)
  name = char(currentclustname(c));
    clust = currentclusts.(name);
    clustsize = length(clust);
    [clustmin indexmin] = min(abs(posData(1,1)-clust));
    [clustmax indexmax] = min(abs(posData(end,1)-clust));
    clust = clust(indexmin:indexmax);

    assvel = assignvelOLD(clust, vel);
    fastspikeindex = find(assvel > velthreshold);
    %meanrate = length(fastspikeindex)./(totaltime); %WANT ONLY AT HIGH VEL

    %%%%%%%%%%%%%%%%%%%
    veldata = vel;
    accdata = abs(acc);

    velpowerchart = powermap(veldata, posData, dim, 0, 50);
    velpowerchart = chartinterp(velpowerchart);
    accpowerchart = powermap(accdata, posData, dim, 0, 50);
    accpowerchart = chartinterp(accpowerchart);

    maxtime = max(posDataFast(:,1));
    currentpos = [posDataFast; [maxtime+.03, 0, 0]; [maxtime+.06, 1500, 1500]];

    xvals = currentpos(:,2);
    yvals = currentpos(:,3);
    xmin = min(currentpos(:,2));
    ymin = min(currentpos(:,3));
    xmax = max(currentpos(:,2));
    ymax = max(currentpos(:,3));
    xbins = ceil((xmax)/psize); %number of x
    ybins = ceil((ymax)/psize); %number of y
    xinc = (0:xbins)*psize; %makes a vectors of all the x values at each increment
    yinc = (0:ybins)*psize; %makes a vector of all the y values at each increment


    spikechart = normalizePosData(clust(fastspikeindex), currentpos, dim);
    spikechart = chartinterp(spikechart);



    reshapesize = size(accpowerchart);
    %multiple linear regression of the responses in vector y on the predictors in matrix X.

    [b,bint,resid] = regress(spikechart(:),[velpowerchart(:), accpowerchart(:)]);
    chart = reshape(resid, reshapesize);


    %%%%%%%%%%%%%%%%%%%


    chart = ndnanfilter(chart, 'gausswin', [10/dim, 10/dim], 2, {}, {'symmetric'}, 1);


    chartlin = sort(chart(:));
    chartlin = chartlin(~isnan(chartlin));
    chartnozero = mean(chartlin(find(chartlin>0)));
    chartlinstd = std(chartlin);
    chartlinmedian = median(chartlin);
    chartlinmean = mean(chartlin);


  %  set(0,'DefaultFigureVisible', 'on');
  %  figure
  %  [nr,nc] = size(chart);
  %  colormap('parula');
  %  pcolor([(chart) nan(nr,1); nan(1,nc+1)]);
  %  set(0,'DefaultFigureVisible', 'off');




    meanrate = nanmean(chart(:));
    maxrate = max(chart(:));
    chart(isnan(chart)) = 0;



    %finds maxes
    actualmax = imregionalmax(chart); %maxes are where there is a 1 on this chart


    [I,J] = find(actualmax==1);
    linearmax = sub2ind(size(actualmax), I, J); %linear indices


    %finds areas where firing > 3x mean. those are marked with a 1 on the chart

    [I,J] = find(chart>=chartlinmean+(1*(chartlinstd)));
    chartmax = zeros(size(chart));
    for p=1:length(I)
      chartmax(I(p),J(p)) = 1;
    end
    f = chartmax;


    CC = bwconncomp(chartmax,4); %finds pixes connected by sides
    numfields = 0;
    length(CC.PixelIdxList);
    fieldsize = [];
    centermax = [];
    centermean =[];

  if find(f(:)==1)>0;
    for z=1:length(CC.PixelIdxList)
      [Yindex, Xindex] = ind2sub(size(chartmax),cell2mat(CC.PixelIdxList(z)));
      YM = length(unique(Yindex));
      XM = length(unique(Xindex));

        [centerY, centerX] = ind2sub(size(chartmax),cell2mat(CC.PixelIdxList(z)));
        yvals_real = ybins-centerY;
        yvals_real = (ymax)./ybins * yvals_real;
        xvals_real = (xmax)./xbins * centerX;

        %corner points
        C1 = [417, 365];
        C2 = [854, 380];
        dis = 100;
        for x=1:length(yvals_real);
          disnew1 = pdist([C1; xvals_real(x), yvals_real(x)]);
          disnew2 = pdist([C2; xvals_real(x), yvals_real(x)]);
          disnew = min(disnew1, disnew2);
          if disnew<dis
            dis = disnew;
          end
        end
        if dis*dim/3.5<5
          wantedY = find(yvals_real>345 | yvals_real<388); %these are in the arms
          wantedX = find(yvals_real<=345 | yvals_real>=388); %this is center. finding with Y but these are the X values
          YM = length(unique(yvals_real(wantedY)));
          XM = length(unique(xvals_real(wantedX)));
          fsize = YM+XM;
        else
          fsize = max([YM; XM]);
        end

        fsize = fsize*dim;
        curr = (chart(Yindex, Xindex));
        if fsize>=15 & max(curr(:))>=chartlinmean+(2*(chartlinstd))
        fieldsize(end+1) = fsize;
        %areaind = cell2mat(CC.PixelIdxList(z)); %linear indices of area
        %numfields = numfields+(length(intersect(areaind, linearmax)))
        numfields = numfields+1;
        [centerY, centerX] = ind2sub(size(chartmax),cell2mat(CC.PixelIdxList(z)));

        xbins = ceil((xmax)/psize);
        ybins = ceil((ymax)/psize);


        newchart = zeros(size(chart));
        newchart(centerY, centerX) = chart(centerY, centerX);
        M = max(newchart, [], 'all');
        [centerYmax, centerXmax] = find(newchart==M);
        centerYmax = ybins-centerYmax;
        newchart(find(newchart==0))=NaN;



        %The skewness was defined, in dimensionless units, as the ratio of the third
        %moment of the place field firing rate distribution divided by the cube of the
        %standard deviation (Spiegel 1994).
        mom = (moment(newchart(~isnan(newchart)),3,'all'));
        stddev = nanstd(newchart(~isnan(newchart)), 0,'all').^3;
        skewness = mom./stddev;






        centerXmean = nanmean(centerX);
        centerYmean = nanmean(centerY);
        centerYmean = ybins-centerYmean;

        centerXmax = (xmax)./xbins * centerXmax;
        centerYmax = (ymax)./ybins * centerYmax;
        centermax(end+1:end+2) = [centerXmax(1), centerYmax(1)];

        centerXmean = (xmax)./xbins * centerXmean;
        centerYmean = (ymax)./ybins * centerYmean;
        centermean(end+1:end+2) = [centerXmean, centerYmean];


        allsizes(end+1) = fieldsize(end);
        allcenterXmean(end+1) = centerXmean;
        allcenterYmean(end+1) = centerYmean;
        allcenterXmax(end+1) = centerXmax(1);
        allcenterYmax(end+1) = centerYmax(1);
        allskew(end+1) = skewness;

        if maxrate < .5
          numfields = NaN;
          fieldsize = NaN;
          allsizes(end+1) = NaN;
          allcenterXmean(end+1) = NaN;
          allcenterYmean(end+1) = NaN;
          allcenterXmax(end+1) = NaN;
          allcenterYmax(end+1) = NaN;
          allskew(end+1) = NaN;


        end

      end


    end

    %maximum firing rate >= .5hz


end
    numfields;

    quad = NaN;
    newdata = {name; clustsize; numfields; fieldsize; centermean; centermax};
    output = horzcat(output, newdata);

end
end

end

allsizescenters = [allsizes; allcenterXmax; allcenterYmax; allcenterXmean; allcenterYmean]';




%if you want seperate choice points
xlimmin = [300 300 320 320 320 450 750 780 828 780 780];
xlimmax = [505 450 450 505 505 850 950 950 950 950 950];
ylimmin = [545 422 320 170 000 300 575 420 339 182 000];
ylimmax = [700 545 422 320 170 440 700 575 420 339 182];
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

%1 = 1, 2 and 4,5 grouped as forced arms
%2 = 3 is forced point
%3 = 6 is middle stem
%4 = 7,8 and 10,11 grouped as choice arms
%5 = 9 is free choice point
posQuadmax = zeros(length(allcenterXmax), 1);
for k=1:length(xlimmin)
  inX = find(allcenterXmax > xlimmin(k) & allcenterXmax <=xlimmax(k));
  inY = find(allcenterYmax > ylimmin(k) & allcenterYmax <=ylimmax(k));
  inboth = intersect(inX, inY);
  if (k == 2 | k== 4)        %|k== 1 | k== 5 %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 1;
  elseif k == 3                                 %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 2;
  elseif (k== 1 | k== 5)
    posQuadmax(inboth) = 0;
  elseif k == 6                        %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 3;
  elseif (k == 8 | k== 10 )                %| k== 7 | k== 11          %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 5;
  elseif (k== 7 | k== 11)
    posQuadmax(inboth) = 6;
  elseif k == 9                                    %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 4;
  else
    posQuadmax(inboth) = NaN;
  end
end

posQuadmean = zeros(length(allcenterXmean), 1);
for k=1:length(xlimmin)
  inX = find(allcenterXmean > xlimmin(k) & allcenterXmean <=xlimmax(k));
  inY = find(allcenterYmean > ylimmin(k) & allcenterYmean <=ylimmax(k));
  inboth = intersect(inX, inY);
  if (k == 2 | k== 4)        %|k== 1 | k== 5 %& vel(inboth(z))>threshold
    posQuadmean(inboth) = 1;
  elseif k == 3                                 %& vel(inboth(z))>threshold
    posQuadmean(inboth) = 2;
  elseif (k== 1 | k== 5)
    posQuadmean(inboth) = 0;
  elseif k == 6                        %& vel(inboth(z))>threshold
    posQuadmean(inboth) = 3;
  elseif (k == 8 | k== 10 )                %| k== 7 | k== 11          %& vel(inboth(z))>threshold
    posQuadmean(inboth) = 5;
  elseif (k== 7 | k== 11)
    posQuadmean(inboth) = 6;
  elseif k == 9                                    %& vel(inboth(z))>threshold
    posQuadmean(inboth) = 4;
  else
    posQuadmean(inboth) = NaN;
  end
end

allsizescenters = [allsizes; allcenterXmax; allcenterYmax; posQuadmax'; allcenterXmean; allcenterYmean; posQuadmean'; allskew]';
%for k=1:length(posQuad)
%output(6, k+1) = mat2cell(posQuad(k), 1, 1);
%end

f=output';
