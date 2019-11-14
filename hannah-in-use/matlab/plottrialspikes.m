function f = plottrialspikes(trialoutput, fieldoutput, min_dist)
%input the output from MASSplacefieldnumDIRECTIONALtrials for trial output and min_dist, and fieldoutput from MASSplacefieldnumDIRECTIONAL

fieldoutput = fieldoutput(2:end, :);

trialnames = (fieldnames(trialoutput));
totalcounts = zeros(1,40);
totalcountsnum = 0;
firstcounts =zeros(1,40);
firstcountsnum = 0;
lastcounts =zeros(1,40);
lastcountsnum = 0;
lastnums= 0;
firstnums= 0;
totalnums = 0;
indytotal=zeros(1,40);
indytotal2=zeros(1,40);
indynumsstarttotal=zeros(1,40);
indynumsendtotal=zeros(1,40);
indynumsstarttotal2=zeros(1,40);
indynumsendtotal2=zeros(1,40);
actnum = 0;

for k = 1:length(trialnames)

  currentname = char(trialnames(k));
  currenttrial = trialoutput.(currentname);
  centerX = fieldoutput(k, 6);
  centerY = fieldoutput(k, 7);

  closer = NaN(size(currenttrial,3),1);

  currdist = NaN(size(currenttrial,1), 1, size(currenttrial,3));

  disindex = [];
  actnum = actnum+size(currenttrial,3);
  for j=1:size(currenttrial,3) %this is lap

    dist = 100000;
    currenttrial(:,1,j);
    nonan = find(currenttrial(:,1,j)>0);
    if length(nonan)>0
    %if abs(currenttrial(nonan(end),1,j)-currenttrial(nonan(1),1,j))<4 %length of 40cm should take about 4 seconds max
    for z=1:size(currenttrial,1) %this is spikes in lap
      if currenttrial(z,4,j)>5
      nowdist = pdist([cell2mat(centerX),cell2mat(centerY); currenttrial(z,2,j), currenttrial(z,3,j)]);
      nowdist = nowdist./3.5;

      if currenttrial(z,1,j)<min_dist(actnum,1)
        currdist(z,1,j) = (nowdist-min_dist(actnum,2))*-1;
      else
        currdist(z,1,j) = (nowdist-min_dist(actnum,2));
      end

        if nowdist < dist
          closer(j) = currenttrial(z,1,j);
          disindex(j) = z;
          dist = nowdist;
        end
      end
    end

    %end

    end

  end






%subplot(ceil(length(trialnames)/5), 5, k)
hold on
currentcount = 0;

indynums = 0;
indycount = 0;
indynumsstart = 0;
indynumsend = 0;
if length(find(disindex>0))>=5
for p = 1:length(disindex)
  centerin = disindex(p); %index in center
  if centerin>0
  currdist(centerin,1,p);
  min(currdist(:,1,p));
  %currdist(:,1,p) = currdist(:,1,p)-min(currdist(:,1,p));

  currdist(1:centerin,1,p) = currdist(1:centerin,1,p)*-1;
  notnan = ~isnan(currdist(:,1,p));
  whatwewant = currdist(notnan,1,p);
  whatwewant = whatwewant(find(whatwewant>=-20 & whatwewant<=20));
  [N,edges] = histcounts(whatwewant, [-20:1:20], 'Normalization', 'probability');
  [Nums,edges] = histcounts(whatwewant, [-20:1:20]);
  if mean(~isnan(N))==1
    currentcount = currentcount+1;
    totalcounts = totalcounts+N;
    totalcountsnum = totalcountsnum+1;
    totalnums = totalnums+Nums;
    indynums = indynums+Nums;
    indycount = indycount+1;
    if currentcount == 1
      firstcounts = firstcounts+N;
      firstcountsnum = firstcountsnum+1;
      firstnums = firstnums+Nums;
      indynumsstart = indynumsstart+Nums;
    end
  end
end
  %line(edges(1:end-1)+1,N);
  %hold on
end

if mean(~isnan(N))==1
lastcounts =lastcounts+N;
lastcountsnum = lastcountsnum+1;
lastnums = lastnums+Nums;
indynumsend = indynumsend+Nums;
end

if nansum(indynums)>0
indytotal = indytotal+(indynums./nansum(indynums));
end
if nansum(indynumsstart)>0
indynumsstarttotal = indynumsstarttotal+(indynumsstart./nansum(indynumsstart));
end
if nansum(indynumsend)>0
indynumsendtotal = indynumsendtotal+(indynumsend./nansum(indynumsend));
end

if indycount>0
indytotal2 = indytotal2+(indynums./indycount);
end
indynumsstarttotal2 = indynumsstarttotal2+indynumsstart;
indynumsendtotal2 = indynumsendtotal2+indynumsend;
end

  %for p = 1:length(closer)
  %  if isnan(closer(p))==0
  %    nonan = ~isnan(currenttrial(:,1,p));
  %    currenttrial(nonan,1,p);
  %    trigger = closer(p);
  %    events = sort(currenttrial(nonan,1,p));

  %  end
  %end

end


%THIS IS DOING ALL AVERAGING TOGETHER
figure
subplot(2,1,1)
hold on
firstcounts = (1./sum(firstcounts))*firstcounts;
lastcounts = (1./sum(lastcounts))*lastcounts;
totalcounts = (1./sum(totalcounts))*totalcounts;
line(edges(1:end-1)+1, firstcounts, 'Color', 'red');
line(edges(1:end-1)+1, lastcounts, 'Color', 'blue');
line(edges(1:end-1)+1, totalcounts, 'Color','black');
legend('Average of all first runs through all fields', 'Average of all last runs through all fields', 'All runs through all fields')
title('Spiking as a function of location around place field center, all trials and all fields')
ylabel('Average proportion of spiking at location')
xlabel('cm from place field center')

%subplot(3,1,2)
%hold on
%line(edges(1:end-1)+1, firstnums./sum(firstnums), 'Color', 'red');
%line(edges(1:end-1)+1, lastnums./sum(lastnums), 'Color', 'blue');
%line(edges(1:end-1)+1, totalnums./sum(totalnums), 'Color','black');

subplot(2,1,2)
hold on
line(edges(1:end-1)+1, firstnums./firstcountsnum, 'Color', 'red');
line(edges(1:end-1)+1, lastnums./lastcountsnum, 'Color', 'blue');
line(edges(1:end-1)+1, totalnums./totalcountsnum, 'Color','black');
legend('Average of all first runs through all fields', 'Average of all last runs through all fields', 'All runs through all fields')
title('Spiking as a function of location around place field center, all trials and all fields')
ylabel('Average spikes at location (spikes/cm)')
xlabel('cm from place field center')


%THIS IS DOING AVERAGING BY FIELD
figure
subplot(2,1,1)
hold on

line(edges(1:end-1), indynumsstarttotal./sum(indynumsstarttotal), 'Color', 'red')
line(edges(1:end-1), indynumsendtotal./sum(indynumsendtotal), 'Color', 'blue')
line(edges(1:end-1), indytotal./sum(indytotal), 'Color', 'black')

subplot(2,1,2)
line(edges(1:end-1), indynumsstarttotal2./firstcountsnum, 'Color', 'red')
line(edges(1:end-1), indynumsendtotal2./firstcountsnum, 'Color', 'blue')
line(edges(1:end-1), indytotal2./firstcountsnum, 'Color', 'black')







f = [edges(1:end-1)+1;firstcounts; lastcounts; totalcounts];
