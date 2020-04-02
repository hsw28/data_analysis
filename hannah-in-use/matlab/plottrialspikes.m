function f = plottrialspikes(trialoutput, fieldoutput, min_dist)
%input the output from MASSplacefieldnumDIRECTIONALtrials for trial output and min_dist, and fieldoutput from MASSplacefieldnumDIRECTIONAL

fieldoutput = fieldoutput(2:end, :);

trialnames = (fieldnames(trialoutput));

bins = 40;

totalcounts = zeros(1,bins);
totalcountsnum = 0;
firstcounts =zeros(1,bins);
firstcountsnum = 0;
lastcounts =zeros(1,bins);
lastcountsnum = 0;
lastnums= 0;
firstnums= 0;
totalnums = 0;
indytotal=zeros(1,bins);
indytotal2=zeros(1,bins);
indynumsstarttotal=zeros(1,bins);
indynumsendtotal=zeros(1,bins);
indynumsstarttotal2=zeros(1,bins);
indynumsendtotal2=zeros(1,bins);
actnum = 1;
lapcenterdist = [];
indynumsstarttotal2error = [];
indynumsendtotal2error = [];
indytotal2error  = [];
totalnumserror = [];
firstnumserror = [];
lastnumserror = [];
totalskewto = [];
totalskewaway = [];
skew = [];
totskew = [];
firstskew = [];
lastskew = [];
currquad = [];
%length(trialnames) %254

for k = 1:length(trialnames) %this is field


  currentname = char(trialnames(k))
  currenttrial = trialoutput.(currentname);

%try without this
  centerX = fieldoutput(k, 6);
  centerY = fieldoutput(k, 7);
  fieldsize = fieldoutput(k, 1);
  size(fieldoutput,2);
  if size(fieldoutput,2)==12
    fieldquad = fieldoutput(k, 12);
  else
    fieldquad = {1};
  end

  closer = NaN(size(currenttrial,3),1);

  currdist = NaN(size(currenttrial,1), 1, size(currenttrial,3));

  disindex = [];
  skew = 0;
  skewcount = 0;
size(currenttrial,3);
  for j=1:size(currenttrial,3) %this is lap

    dist = 100000;
    currenttrial(:,1,j);
    nonan = find(currenttrial(:,1,j)>0);
    if length(nonan)>0
    for z=1:size(currenttrial,1) %this is spikes in lap
      if currenttrial(z,4,j)>5
      nowdist = pdist([cell2mat(centerX),cell2mat(centerY); currenttrial(z,2,j), currenttrial(z,3,j)]);
      nowdist = nowdist./3.5;

      currdist(z,1,j) = (nowdist);

      if nowdist < dist
      closer(j) = currenttrial(z,1,j);
      disindex(j) = z;
      dist = nowdist;
    end
      end
    end

    %  skews = skew+min_dist(actnum,7); %SKEW
    %  skew(j) = min_dist(actnum,7);
    %  skewcount = skewcount+1;

      currquad(j) = cell2mat(fieldquad);
    end


cell2mat(centerX);
cell2mat(centerY);
min_dist(actnum,3);
min_dist(actnum,4);
    compcentdist = pdist([cell2mat(centerX),cell2mat(centerY); min_dist(actnum,3),min_dist(actnum,4)]);
    compcentdist = (compcentdist./3.5)-min_dist(actnum,2);

    %compcentdist = min_dist(actnum,5)-min_dist(actnum,2);

    if nanmean(currenttrial((1:end),1,:))>=3;
      lapcenterdist = [lapcenterdist; j, compcentdist, cell2mat(fieldquad)];

    end




  %  if min_dist(actnum-1,6)==1
      %totalskewto(end+1) = skews./skewcount;
  %  else
    %totalskewaway(end+1) = skews./skewcount;
  %  end


%TAKING OUT
%actnum = actnum+1;
%    end





%end MAYBE??



actnum;





currentcount = 0;

indynums = 0;
indycount = 0;
indynumsstart = 0;
indynumsend = 0;
haveaddedfirst = 1;
haveaddedlast = 1;
  c = 1;
if length(find(disindex>0))>=15
  wantedindex = find(disindex>0);
  templast1 = nan(1,bins);
  tempskew = nan(1,3);

  for p = 1:length(disindex)

  centerin = disindex(p); %index in center

    if centerin>0

      %currdist(1:centerin,1,p) = currdist(1:centerin,1,p)*-1;

      currdist(1:centerin,1,p) = currdist(1:centerin,1,p)*-1+min_dist(actnum,2);
      currdist(centerin:end,1,p) = currdist(centerin:end,1,p)-min_dist(actnum,2);

      currdist(~isnan(currdist(:,1,p)),1,p);
      notnan = ~isnan(currdist(:,1,p));
      whatwewant = currdist(notnan,1,p);
      whatwewant = whatwewant(find(whatwewant>=-20 & whatwewant<=20));
      [N,edges] = histcounts(whatwewant, [-20:40/bins:20], 'Normalization', 'probability');
      [Nums,edges] = histcounts(whatwewant, [-20:40/bins:20]);


        if mean(~isnan(N))==1
        currentcount = currentcount+1;
        indynums = indynums+Nums;
        indycount = indycount+1;
      %  totskew(end+1) = skew(p);

        totalcountsnum = totalcountsnum+1;
        totalnums = totalnums+Nums;
        totalnumserror = [totalnumserror; Nums];


        if haveaddedfirst <= 5
          firstcountsnum = firstcountsnum+1;
          firstnums = firstnums+Nums;
          firstnumserror = [firstnumserror; Nums];
          haveaddedfirst = haveaddedfirst+1;
          haveaddedfirst;
        %  firstskew(end+1) = skew(p);
        end

        if isnan(Nums)==0
        templast1(c,:) = Nums;
      %  tempskew(c) = skew(p);
        c=c+1;
        if c == 5 & isnan(Nums)==0
          c = 1;
        end
      end


        end
      end
    end


if haveaddedfirst>5
lastcountsnum = lastcountsnum+size(templast1,1);
lastnums = lastnums+sum(templast1);
lastnumserror = [lastnumserror; templast1];
lastskew = [lastskew, tempskew];

end




  %lastcountsnum = lastcountsnum+2;
  %lastnums = lastnums+templast1+templast2+templast3;
    %lastnumserror = [lastnumserror; templast1; templast2; templast3];
end
actnum = actnum+1;
   end

end

if actnum ~= length(min_dist)
  actnum = actnum
  length(min_dist)
  warning('measurements dont line up')
end


figure
subplot(2,1,1)
histogram(totalskewto, 'BinWidth', .2)
nanmean(totalskewto)
nanmedian(totalskewto)
subplot(2,1,2)
histogram(totalskewaway, 'BinWidth', .2)
nanmean(totalskewaway)
nanmedian(totalskewaway)

%totskewmean = nanmean(totskew)
%firstskewmean = nanmean(firstskew)
%lastskewmean = nanmean(lastskew)
%diffskew = nanmean(abs(lastskew-firstskew))


%THIS IS DOING ALL AVERAGING TOGETHER
%subplot(2,1,2)
figure
hold on


%{
totalnumserrorminus = totalnumserror;
[row, ~] = ismember(firstnumserror,totalnumserrorminus);
totalnumserrorminus(col) = [];
[col, ~] = ismember(lastnumserror,totalnumserrorminus);
totalnumserrorminus(col) = [];
totalnumserrorminusnums = length(totalnumserrorminus);
%}

totalnumserrorminus = totalnumserror;
[ia, ib] = ismember(totalnumserrorminus, firstnumserror, 'rows');
totalnumserrorminus(ia, :) = []
totalnumserrorminus = totalnumserror;
[ia, ib] = ismember(totalnumserrorminus, lastnumserror, 'rows');
totalnumserrorminus(ia, :) = []
totalnumserrorminusnums = length(totalnumserrorminus);



errorbar(edges(1:end-1)+1, firstnums./firstcountsnum./2, std(firstnumserror./2)./sqrt(firstcountsnum),'Color', 'red');
%errorbar(edges(1:end-1)+1, nansum(totalnumserrorminus)./totalnumserrorminusnums./2, std(totalnumserrorminus./2)./sqrt(totalnumserrorminusnums), 'Color','black');
errorbar(edges(1:end-1)+1, lastnums./lastcountsnum./2, std(lastnumserror./2)./sqrt(lastcountsnum), 'Color', 'black');
%errorbar(edges(1:end-1)+1, totalnums./totalcountsnum./2, std(totalnumserror./2)./sqrt(totalcountsnum), 'Color','black');

legend('Average of all first runs through all fields', 'Average of all last runs through all fields')
%legend('Average of all first runs through all fields', 'Average of all last runs through all fields')
title('Spiking as a function of location around place field center, all trials and all fields')
ylabel('Average spikes at location (spikes/cm)')
xlabel('cm from place field center')

%figure
%plot(edges(1:end-1)+1, totalnumserror)


ttresults = [];
ttresults2 = [];
ttresults3 = [];
ttresults4 = [];
ttresults5 = [];



for c = 1:size(firstnumserror,2)

  [m p n stats] = ttest2(firstnumserror(:,c), lastnumserror(:,c));
    ttresults(end+1) = p;
    if p<0.05
      fl = c;
      fl = p;
    end
    %[m p n stats4] = ttest(firstnumserror(:,c), mean(totalnumserror(:,c)));
    %  ttresults4(end+1) = p;
    %  if p<0.05
    %    fa = c;
    %    fa = p;
    %  end

  %if c == bins./2+1
%  if c == bins/2+1
%    mean(firstnumserror(:,c))./2;
%    mean(lastnumserror(:,c))./2;
%    mean(totalnumserror(:,c))./2;
%    std(firstnumserror(:,c)./2);
%    std((lastnumserror(:,c)./2));
%    std((totalnumserror(:,c)./2));


%  end
end
%}

fprintf('GOT HERE')
ttresults
%ttresults2
%ttresults3

%ttresults5



%errorbar(edges(1:end-1), indytotal2./firstcountsnum, std(indytotal2error)./size(indytotal2error,1), 'Color', 'black')
%size(indytotal2error,1)

%legend('Average of all first runs through all fields', 'Average of all last runs through all fields', 'All runs through all fields')
%title('Spiking as a function of location around place field center, all trials and all fields')
%ylabel('Average proportion of spiking at location')
%xlabel('cm from place field center')



toplot = [];

for z=1:max(lapcenterdist(:,1))
  found = find(lapcenterdist(:,1)==z);
  meandist = nanmean(lapcenterdist(found,2));
  stderrorlap = nanstd(lapcenterdist(found,2))./sqrt(length(found));
  toplot = [toplot; z, meandist, length(found), stderrorlap];
end


figure

wanted = find(toplot(:,3)>=30);
wanted = max(wanted);
x = toplot(1:wanted,1);
y = toplot(1:wanted,2);
%[k, yInf, y0, yFit] = fitL(x, y);
%k = k
%yInf = yInf
%y0 = y0

fitlm(x,y);
scatter(x,y);
hold on
errorbar(x, y, toplot(1:wanted,4), 'LineStyle','none');

coefficients = polyfit(x, y, 1);
xFit = linspace(min(x), max(x), 1000);
yFit = polyval(coefficients , xFit);
hold on;
%plot(xFit, yFit, 'r-', 'LineWidth', 2);

%plot(x, yFit)
title('Place field centers converge with experience')
xlabel('Lap')
ylabel('Average distance of lap place field center from overall center (cm)')





%toplot = [];


figure

for m=1:3
  toplot = [];
  if m==1 %forced
    wantedquad = [0,1];
    color = [1,0,0];
  elseif m==2 %middle
    wantedquad = [3,3];
    color = [0,0,1];
  elseif m==3 %choice
    wantedquad = [5,6];
    color = [.58,0,.83];
  end


  toplot =[];
  for z=1:max(lapcenterdist(:,1))
    found1 = find(lapcenterdist(:,1)==z);
    found2 = find(lapcenterdist(:,3)==wantedquad(1) | lapcenterdist(:,3)==wantedquad(2));
    found = intersect(found1,found2);
    meandist = nanmean(lapcenterdist(found,2));
    stderrorlap = nanstd(lapcenterdist(found,2)./3.5)./sqrt(length(found));

    toplot = [toplot; z, meandist, length(found), stderrorlap];
  end
  wanted = find(toplot(:,3)>=5);
  wanted = max(wanted);
  x = toplot(1:wanted,1);
  y = toplot(1:wanted,2)./3.5;
  hold on
  scatter(x,y,[], color)
  coefficients = polyfit(x, y, 1);
  f = polyval(coefficients,x);
  plot(x,f, 'Color', color)


end



%figure

%fitlm(x,y)
%[fitobject,gof] = fit(x,y,'exp1')



%size(nanmean(firstnumserror'))
%size((mean(totalnumserror)))
%[m p n stats] = ttest(nanmean(firstnumserror'), nanmean(lastnumserror'))
%[m p n stats] = ttest2(nanmean(firstnumserror'), mean((totalnumserror')))
f = lapcenterdist;
