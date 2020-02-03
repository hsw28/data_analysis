function [f allsizescenters tempz] = MASSplacefieldnum(clusters,posstructure, dim)

     set(0,'DefaultFigureVisible', 'off');

%determine how many spikes & pos files

allsizes = [];
allcenterXmean = [];
allcenterYmean = [];
allcenterXmax = [];
allcenterYmax = [];
allskew = [];
fieldmeanrate = [];
allmeanratetet = [];
clustspikenames = (fieldnames(clusters));
spikenum = length(clustspikenames);
allmaxrate = [];
tetmean = [];
porp = [];
tempz = [];

posnames = (fieldnames(posstructure));
posnum = length(posnames);
pnames = {};
for s = 1:posnum
  if contains(posnames(s), 'position')==1
    pnames(end+1) = (posnames(s));
  end
end

output = {'cluster name'; 'cluster size'; 'num of fields'; 'field size in cm'; 'centermax'; 'centermean'; 'meanrate'};


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


  currentclusts = struct;
  cstart = 0;
  cend = 100000000;
  for c = 1:(spikenum)
    name = char(clustspikenames(c));
    date;
    if contains(name, date)==1 & cstart==0
      [currentclusts(:).(name)] = deal(clusters.(name));
    end
  end

  currentclustname = (fieldnames(currentclusts))
  currentnumclust = length(currentclustname);

  if currentnumclust>0


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



    figure
    chart = normalizePosData(clust(fastspikeindex), posDataFast, dim);

      chart = chartinterp(chart);
      chart = ndnanfilter(chart, 'gausswin', [10/dim, 10/dim], 2, {}, {'symmetric'}, 1);


      chartlin = sort(chart(:));
      chartlin = chartlin(~isnan(chartlin));
      chartnozero = mean(chartlin(find(chartlin>0)));
      chartlinstd = std(chartlin);
      chartlinmedian = median(chartlin);
      chartlinmean = mean(chartlin);




    %divided into 5cm by 5cm bins
    %place fields are 5 or more adjacent pix
    %should have only one peak

    meanrate = nanmean(chart(:));
    maxrate = max(chart(:));


    chart(isnan(chart)) = 0;

    %tempz(:,end+1) = [chartnozero, chartlinmean, chartlinmedian, chartlinstd];
    %tempz = chartlin;
    %finds maxes
    actualmax = imregionalmax(chart); %maxes are where there is a 1 on this chart


    [I,J] = find(actualmax==1);
    linearmax = sub2ind(size(actualmax), I, J); %linear indices

    %finds areas where firing > 3x mean
    %[I,J] = find(chart>=3*meanrate);
      %[I,J] = find(chart>=2.5*chartlinmean);
      %[I,J] = find(chart>=2.75*chartlinmean); %TRYING
      [I,J] = find(chart>=chartlinmean+(1*(chartlinstd)));





    meanrates = meanrate;
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

        numfields = numfields+1;
        [centerY, centerX] = ind2sub(size(chartmax),cell2mat(CC.PixelIdxList(z)));


        %converts indices to actual values

        realX = (xmax)./xbins .* centerX;
        realY = (ymax)./ybins .* centerY;
        currentrates = chart(centerY, centerX);
        fieldmeanrate(end+1)= nanmean(currentrates(:));




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

        porp(end+1) = (nanmean(currentrates(:)))./maxrate;




        centerXmax = (xmax)./xbins * centerXmax;
        centerYmax = (ymax)./ybins * centerYmax;
        centermax(end+1:end+2) = [centerXmax(1), centerYmax(1)];

        centerXmean = nanmean(centerX);
        centerYmean = nanmean(centerY);
        centerYmean = ybins-centerYmean;
        centerXmean = (xmax)./xbins * centerXmean;
        centerYmean = (ymax)./ybins * centerYmean;
        centermean(end+1:end+2) = [centerXmean, centerYmean];

        allsizes(end+1) = fieldsize(end);
        allcenterXmean(end+1) = centerXmean;
        allcenterYmean(end+1) = centerYmean;
        allcenterXmax(end+1) = centerXmax(1);
        allcenterYmax(end+1) = centerYmax(1);
        allskew(end+1) = skewness;
        allmeanratetet(end+1) = meanrate;
        allmaxrate(end+1) = maxrate;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %5 used to be 440 820 340 420
                xlimmin = [300 300  750 780 ];
                xlimmax = [505 505  950 950 ];
                ylimmin = [370 000  380 000 ];
                ylimmax = [700 370  700 380 ];


                for k=1:length(xlimmin)
                  if centerYmean<380 & centerYmean>340 & size(newchart,2)>size(newchart,1)%center area so place field could go horizontally or vertically
                        k=5;
                        flattened = nanmean(newchart,1);
                        newflattened = flattened;

                    else
                        inX = find(centerXmean > xlimmin(k) & centerXmean <=xlimmax(k)); %check to make sure correct indexing
                        inY = find(centerYmean > ylimmin(k) & centerYmean <=ylimmax(k));
                        inboth = intersect(inX, inY);
                        if length(inboth)>0
                          flattened = nanmean(newchart,2)'; %need this directional
                          %need to flip right forced and left choice
                          if (k == 1 | k== 4)
                            newflattened = flattened;
                          elseif (k == 2 | k== 3)
                            newflattened = flip(flattened);
                          end


                      end
                  end
                end

                flatstart = (find(newflattened>0));
                newflattened = newflattened(flatstart(1):end);

                counter = 0;
                flatmean = 0;
                countersum = 0;


                for kk = 1:length(newflattened)
                  if newflattened(kk)>0
                  flatmean = flatmean+(kk*newflattened(kk));
                  counter = counter+1;
                  countersum = countersum+newflattened(kk);
                  end
                end
                flatmean = flatmean./countersum;

                flatmom = 0;
                temp = [];
                for kk = 1:length(newflattened)
                  if newflattened(kk)>0
                    kk-flatmean;
                    temp(end+1)= ((kk-flatmean)^3)*newflattened(kk);
                  flatmom = flatmom+((kk-flatmean)^3)*newflattened(kk);
                  end
                end


                flatstd = 0;
                for kk = 1:length(newflattened)
                  if newflattened(kk)>0
                  flatstd = flatstd+((kk-flatmean)^2)*newflattened(kk);
                end
                end

                flatstd = sqrt(flatstd);

                if length(newflattened(~isnan(newflattened)))>2
                  skewness = flatmom./(flatstd^3)
                else
                  skewness = NaN;
                end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if maxrate < .5
          numfields = NaN;
          fieldsize = NaN;
          allsizes(end+1) = NaN;
          allcenterXmean(end+1) = NaN;
          allcenterYmean(end+1) = NaN;
          allcenterXmax(end+1) = NaN;
          allcenterYmax(end+1) = NaN;
          allskew(end+1) = NaN;
          tetmean(end+1) = NaN;


        end

      end


    end

    %maximum firing rate >= .5hz



    numfields;

    quad = NaN;
    newdata = {name; clustsize; numfields; fieldsize; centermean; centermax; meanrates};
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



allsizescenters = [allsizes; allcenterXmax; allcenterYmax; posQuadmax'; allcenterXmean; allcenterYmean; posQuadmean'; allskew; allmaxrate; fieldmeanrate; porp]';
%for k=1:length(posQuad)
%output(6, k+1) = mat2cell(posQuad(k), 1, 1);
%end

f=output';
