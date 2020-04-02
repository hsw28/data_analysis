function [f mindistall]= MASSplacefieldnumDIRECTIONALtrials(clusters,posstructure, dim, fieldchart)
%outputs location of each spike around field center as defined from MASSplacefieldnumDIRECTIONAL
%fieldchart is output from MASSplacefieldnumDIRECTIONAL
%output is:
% f is a structure for each place cell with each structure (a,b,c) where a is each spike, c is the lap number, and b is time, x pos, y pos, velocity
% mindistall is a (:,4) matrix where columns:
  %1 is the time the animal passes by center as defined by MASSplacefieldnumDIRECTIONAL
  %2 is the distance from the center
  %3 is the X of max spiking for that lap
  %4 is the Y of max spiking for that lap



set(0,'DefaultFigureVisible', 'off');
%determine how many spikes & pos files
allsizes = [];
allcenterXmean = [];
allcenterYmean = [];
allcenterXmax = [];
allcenterYmax = [];
allskew = [];
alldir = [];
alldirskew = [];
clustspikenames = (fieldnames(clusters));
spikenum = length(clustspikenames);
allavpfrate = [];
allmaxpfrate = [];
pastname = 'aaaaaaaaaaaaaasaaaaaaaaaaa';
mindistall = [];
test = 0;
totsallnumb = 1;

posnames = (fieldnames(posstructure));
posnum = length(posnames);
pnames = {};
for s = 1:posnum
  if contains(posnames(s), 'position')==1
    pnames(end+1) = (posnames(s));
  end
end

fieldoutput = fieldchart(2:end, :);
fieldchart= fieldchart(2:end, :);
size(fieldoutput);

output = {'cluster name'; 'cluster size'; 'direction'; '1=to, 2=away'; 'field size in cm'; 'centermax X'; 'centermax Y'; 'skewness'; 'dir skewness'; 'av field rate'; 'max field rate'};

for z = 1:size(fieldoutput,1)

  fieldname = char(cell2mat(fieldoutput(z,1)))
  currentclusts = struct;
  for w=1:length(clustspikenames)
    currclust = char(clustspikenames(w)); %determining cluster
    if contains(currclust, fieldname) == 1
      name = char(clustspikenames(w));
      [currentclusts(:).(name)] = deal(clusters.(name));
      break
    end
  end
  currentclustname = (fieldnames(currentclusts));
  currentnumclust = length(currentclustname);
  name = char(currclust);
  clust = currentclusts.(name);

  cnames = {};
  cstart = 0;
  cend = 100000000;

    for c = 1:posnum
      currentname = char(posnames(c));
      noposdate = strsplit(currentname,'date_'); %splitting at year rat12_2018_08_20_time
      noposdate = char(noposdate(1,2));
      noposdate = strsplit(noposdate,'_position'); %rat12_2018_08_20
      noposdate = char(noposdate(1,1));

      if contains(fieldname, noposdate)==1 & cstart==0 & contains(currentname, 'position')==1
        currentname = currentname;
        posData = posstructure.(currentname);
        posData(:,2) = smoothdata(posData(:,2), 'gaussian', 10);
        posData(:,3) = smoothdata(posData(:,3), 'gaussian', 10);
        break
      end
    end



  if nanmean(currentname(length(currentname)-22:end) == pastname(length(pastname)-22:end))<1
      posData = fixpos(posData);
      fprintf('NEW DATE')
      pastname = currentname;


    %finding directionality for all positions
    dirinfo = direction(posData(:,1), posData); %outputs [timevector; xposvector; yposvector; fxvector; fyvector];

    %if left forced or right choice is negative in y direction, toward reward
    %if right forced or left choice is positive in y direction, toward reward
    %if middle is positive in x direction, toward reward
    %if middle is negative in x direction, away from reward
            %   1   2   3   4   5
    xlimmin = [300 300  750 780 430];
    xlimmax = [505 505  950 950 870];
    ylimmin = [370 000  380 000 300];
    ylimmax = [700 370  700 380 440];

      toreward = [];
      awayreward = [];
      for k=1:length(xlimmin)

        inX = find(dirinfo(2,:) > xlimmin(k) & dirinfo(2,:) <=xlimmax(k)); %check to make sure correct indexing
        inY = find(dirinfo(3,:) > ylimmin(k) & dirinfo(3,:) <=ylimmax(k));
        inboth = intersect(inX, inY);
        if (k == 1 | k== 4) %if left forced or right choice is negative in y direction, toward reward
          yneg = find(dirinfo(5,:)<0);
          ypos = find(dirinfo(5,:)>0);
          toreward = [toreward, intersect(inboth, yneg)]; %indices of to
          awayreward = [awayreward, intersect(inboth, ypos)];

        elseif (k == 2 | k== 3) %if right forced or left choice is positive in y direction, toward reward
          yneg = find(dirinfo(5,:)<0);
          ypos = find(dirinfo(5,:)>0);
          awayreward = [awayreward, intersect(inboth, yneg)]; %indices of to
          toreward = [toreward, intersect(inboth, ypos)];
        elseif (k == 5) %if middle is positive in x direction, toward reward
          xneg = find(dirinfo(4,:)<0);
          xpos = find(dirinfo(4,:)>0);
          toreward = [toreward, intersect(inboth, xpos)]; %indices of to
          awayreward = [awayreward, intersect(inboth, xneg)];
        end
      end


      torewardpos = dirinfo(1:3,toreward);
      awayrewardpos = dirinfo(1:3,awayreward);


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
    end



    clustsize = length(clust);
    [clustmin indexmin] = min(abs(posData(1,1)-clust));
    [clustmax indexmax] = min(abs(posData(end,1)-clust));
    clust = clust(indexmin:indexmax);

    assvel = assignvelOLD(clust, vel);
    %fastspikeindex = find(assvel > velthreshold);



      dirinfo = direction(clust, posData); %outputs [timevector; xposvector; yposvector; fxvector; fyvector];


      toreward = [];
      awayreward = [];
      for k=1:length(xlimmin)

        inX = find(dirinfo(2,:) > xlimmin(k) & dirinfo(2,:) <=xlimmax(k)); %check to make sure correct indexing
        inY = find(dirinfo(3,:) > ylimmin(k) & dirinfo(3,:) <=ylimmax(k));
        inboth = intersect(inX, inY);
        if (k == 1 | k== 4) %if left forced or right choice is negative in y direction, toward reward
          yneg = find(dirinfo(5,:)<0);
          ypos = find(dirinfo(5,:)>0);
          toreward = [toreward, intersect(inboth, yneg)]; %indices of to
          awayreward = [awayreward, intersect(inboth, ypos)];

        elseif (k == 2 | k== 3) %if right forced or left choice is positive in y direction, toward reward
          yneg = find(dirinfo(5,:)<0);
          ypos = find(dirinfo(5,:)>0);
          awayreward = [awayreward, intersect(inboth, yneg)]; %indices of to
          toreward = [toreward, intersect(inboth, ypos)];
        elseif (k == 5) %if middle is positive in x direction, toward reward
          xneg = find(dirinfo(4,:)<0);
          xpos = find(dirinfo(4,:)>0);
          toreward = [toreward, intersect(inboth, xpos)]; %indices of to
          awayreward = [awayreward, intersect(inboth, xneg)];
        end
      end


      torewardspikes = dirinfo(1,toreward);
      awayrewardspikes = dirinfo(1,awayreward);


      currentdir = cell2mat(fieldchart((z),4));
        if cell2mat(fieldchart((z),4)) == 1 %towards reward
          usespikes = torewardspikes;
          usespos = torewardpos;
        else
          usespikes = awayrewardspikes;
          usespos = awayrewardpos;
        end

        usecenterX = cell2mat(fieldchart((z),6));
        usecenterY = cell2mat(fieldchart((z),7));
        usecentersize = cell2mat(fieldchart((z),5));

        %want to find every time animal passed through field going the correct direction
        %all positions in question: usespos
        %all spikes in question: usespikes


        disty = [];
        for qq = 1:size(usespos,2)
        disty(end+1) = pdist([usecenterX, usecenterY; usespos(2,qq), usespos(3,qq)]); %finds distance to center
        end

        distyclose = find((disty)<(15*3.5)); %indices of times when close (less than 15 cm from center)
        distyclosetimes = usespos(1,distyclose); %times close to field
        distyclosedist = disty(distyclose); %distances close to field


        %find spiking in 2 second increments
        %diff does second minus first
        differences = abs(diff(distyclosetimes));
        newpass = 1;
        newpass = [newpass, find(differences > 1)]; %if more than two seconds apart, a different pass


        %NEW PASS IS THE INDICES FOR EACH NEW PASS, FROM DIFFERENCES (which had indices of distyclose), NOT TIMES OR POSITIONS

        mindist = [];
        mintime = [];
        for np=1:length(newpass)-1
          currdistyclosedist = distyclosedist(newpass(np):newpass(np+1));
          currdistyclosetimes = distyclosetimes(newpass(np):newpass(np+1));
          [val minindex] = min(currdistyclosedist);
        currdistyclosetimes(minindex);
          mindist(end+1) = currdistyclosedist(minindex); %minimum distance
          mintime(end+1) = currdistyclosetimes(minindex); %minimum time
        end

        %newpass is the indices of passes
        oldpassstart = 0;
        numpass = 1;
        goodfield = NaN(500, 4);
        for qqq=1:length(mintime) %going through passes
           if length(newpass)>2 & length(distyclose)>0

           mintime(qqq); %time closest to field
           mindist(qqq); %distance closest to field

           qqq;

           %find all spikes within 20cm of center
           [closetime closeindex] = min(abs(posData(:,1)-mintime(qqq)));
           db = closeindex;
           currdist = 0;
           while currdist<20*3.5 & db>0 %finding before 20cm
             currdist = pdist([posData(db,2), posData(db,3); usecenterX, usecenterY]);
             db = db-1;
           end

           da = closeindex;
           currdist = 0;

           while currdist<20*3.5 & da<length(posData) %finding after 20cm
             currdist = pdist([posData(da,2), posData(da,3); usecenterX, usecenterY]);
             da = da+1;
           end

           if db==0
             db = 1;
           end
           if da==length(posData)
             da = da-1;
           end
           passstart = posData(db,1);
           passend = posData(da,1);


           if passstart~=oldpassstart
            oldpassstart = passstart;
           passspikes1 = find(usespikes>=passstart);
           passspikes2 = find(usespikes<=passend);
           passspikes = intersect(passspikes1, passspikes2); %spike indices windows
           passspikes = sort(usespikes(passspikes)); %actual spikes times in window

           qqq;

            if length(passspikes)>0 %if there are any spikes in the window, assign positions to them


              passpos = assignposOLD(passspikes, posData); %positions assigned to spikes
                currvel = assignvelOLD(passspikes, vel);
                currvel = currvel(1:size(passpos,1));


                chart = normalizePosData(passspikes, posData, dim);
                chart = chartinterp(chart);
                chart = ndnanfilter(chart, 'gausswin', [10/dim, 10/dim], 2, {}, {'symmetric'}, 1);

                psize = 3.5 * dim;
                xvals = posData(:,2);
                yvals = posData(:,3);
                xmin = min(posData(:,2));
                ymin = min(posData(:,3));
                xmax = max(posData(:,2));
                ymax = max(posData(:,3));
                xbins = ceil((xmax)/psize); %number of x
                ybins = ceil((ymax)/psize); %number of y

                M = max(chart, [], 'all');
                [centerYmax, centerXmax] = find(chart==M);
                centerYmax = centerYmax(1);
                centerXmax = centerXmax(1);
                centerYmax = ybins-centerYmax;
                centerXmax = (xmax)./xbins * centerXmax;
                centerYmax = (ymax)./ybins * centerYmax;

                compcentdist = pdist([usecenterX,usecenterY; centerXmax, centerYmax]);

                totsallnumb;
                if qqq==1

                  goodfield(1:length(currvel),:,(qqq)) = [passpos, currvel'];
                  mindistall(totsallnumb,:) =  [mintime(qqq), mindist(qqq)./3.5, centerXmax, centerYmax, compcentdist./3.5, cell2mat(fieldchart((z),4))]; % put time and min distance in vector for output
                  totsallnumb = totsallnumb+1;
                else

              %  elseif length(find(passpos(1,1,1)==goodfield(1,1,:)))<1
                  goodfield(1:length(currvel),:,(end+1)) = [passpos, currvel'];

                  mindistall(totsallnumb,:) =  [mintime(qqq), mindist(qqq)./3.5, centerXmax, centerYmax, compcentdist./3.5, cell2mat(fieldchart((z),4))]; % put time and min distance in vector for output


                  totsallnumb = totsallnumb+1;
                end

                numpass = numpass+1;

                %%%%%%%%%%%%%SKEWWWWWWWW
                        xlimmin = [300 300  750 780 ];
                        xlimmax = [505 505  950 950 ];
                        ylimmin = [370 000  380 000 ];
                        ylimmax = [700 370  700 380 ];


                        for k=1:length(xlimmin)
                          if centerYmax<380 & centerYmax>340 & size(chart,2)>size(chart,1)%center area so place field could go horizontally or vertically
                                k=5;
                                flattened = nanmean(chart,1);
                                newflattened = flattened;
                            else
                                inX = find(centerXmax > xlimmin(k) & centerXmax <=xlimmax(k)); %check to make sure correct indexing
                                inY = find(centerYmax > ylimmin(k) & centerYmax <=ylimmax(k));
                                inboth = intersect(inX, inY);
                                if length(inboth)>0
                                  flattened = nanmean(chart,2)'; %need this directional
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

                        newflattened(isnan(newflattened)) = 0;
                        newflattened(find(newflattened<.001)) = 0;


                        zpos = find(~[0 newflattened 0]);
                        [~, grpidx] = max(diff(zpos));
                        newflattened = newflattened(zpos(grpidx):zpos(grpidx+1)-2);

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
                          skewness = flatmom./(flatstd^3);
                        else
                          skewness = NaN;
                        end

                        if currentdir == 1
                          dirskewness = skewness;
                        elseif currentdir ==2
                          dirskewness = skewness.*-1;
                        end


                        if dirskewness>20
                          dirskewness
                        newflattened
                      end


                %%%%%%%%%%%%%SKEWWWWWWWW
                %[size(mindistall), size(mintime(qqq)), size(mindist(qqq)./3.5), size(centerXmax), size(centerYmax), size(compcentdist./3.5), size(cell2mat(fieldchart((z),4))), size(dirskewness)];

                %mindistall =  [mindistall; mintime(qqq), mindist(qqq)./3.5, centerXmax, centerYmax, compcentdist./3.5, cell2mat(fieldchart((z),4)), dirskewness]; % put time and min distance in vector for output
            elseif qqq==1
              %mindistall(totsallnumb,:) =  [NaN, NaN, NaN, NaN, NaN, NaN];
              totsallnumb = totsallnumb+1;
            end
          end
          end
          end




          goodfield(goodfield==0) = NaN;
          %mindistall(goodfield==0) =  [NaN, NaN, NaN, NaN, NaN, NaN];

          title = strcat(char(fieldname),'_');
          title = strcat(title, char(num2str(z)));
          allfields.(title) = goodfield;

size(goodfield,3);
test = test+size(goodfield,3);
size(mindistall,1);

while size(mindistall,1)<test %& test~=1
  mindistall =  [mindistall;NaN, NaN, NaN, NaN, NaN, NaN];
  warning('size is too small')
end
if size(mindistall,1)>test
  error('size is too big')
end

mindistall;
totsallnumb = test+1;

end

replace = find(mindistall(:,1)==0)
mindistall(replace,:)=NaN;

  f = allfields;
mindistall;
