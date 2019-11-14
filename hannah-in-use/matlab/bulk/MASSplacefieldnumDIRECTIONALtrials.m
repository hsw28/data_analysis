function [f mindistall]= MASSplacefieldnumDIRECTIONALtrials(clusters,posstructure, dim, fieldchart)
%outputs location of each spike around field center as defined from MASSplacefieldnumDIRECTIONAL
%fieldchart is output from MASSplacefieldnumDIRECTIONAL
%output is:
% f is a structure for each place cell with each structure (a,b,c) where a is each spike, c is the lap number, and b is time, x pos, y pos, velocity
% mindistall is a (:,2) matrix where column one is the time the animal passes by center, and column 2 is the distance from the center




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

%output = {'cluster name'; 'cluster size'; 'direction'; 'num of fields'; 'field size in cm'; 'centermax'; 'centermean'; 'skewness'};
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
      awayrewardpos = dirinfo(1:3,toreward);


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


    %spike rates




    clustsize = length(clust);
    [clustmin indexmin] = min(abs(posData(1,1)-clust));
    [clustmax indexmax] = min(abs(posData(end,1)-clust));
    clust = clust(indexmin:indexmax);

    assvel = assignvelOLD(clust, vel);
    %fastspikeindex = find(assvel > velthreshold);



%%%

%dirinfo = direction(clust(fastspikeindex), posData); %outputs [timevector; xposvector; yposvector; fxvector; fyvector];
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

      testing = intersect(toreward, awayreward);
      dirinfo(:, testing)';
      torewardspikes = dirinfo(1,toreward);
      awayrewardspikes = dirinfo(1,awayreward);



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

        distyclose = find((disty)<(20)); %indices of times when close (less than 15 pixels from center)
        distyclosetimes = usespos(1,distyclose); %times close to field
        distyclosedist = disty(distyclose); %distances close to field


        %find spiking in 2 second increments
        %diff does second minus first
        differences = abs(diff(distyclose));
        newpass = 1;
        newpass = [newpass, find(differences > usecentersize*1.5/10+2)]; %if more than two seconds apart, a different pass
        %NEW PASS IS THE INDICES FOR EACH NEW PASS, FROM DIFFERENCES (which had indices of distyclose), NOT TIMES OR POSITIONS

        mindist = [];
        mintime = [];
        for np=1:length(newpass)-1
          [val minindex] = min(distyclosedist(newpass(np):newpass(np+1)));
          mindist(end+1) = distyclosedist(minindex); %minimum distance
          mintime(end+1) = distyclosetimes(minindex); %minimum time
        end

        %newpass is the indices of passes
        oldpassstart = 0;
        numpass = 1;
        goodfield = NaN(500, 4);
        for qqq=1:length(mintime) %going through passes
           %passtimes = find(abs(usespos(1,:)-usespos(1,newpass(qqq)))<(usecentersize*3.5./10*1.5)); %you get 1.5s for every cm of field size
           if length(newpass)>2 & length(distyclose)>0
           mintime(qqq); %time closest to field
           mindist(qqq); %distance closest to field


           %this shouldnt be time, it should be animal's distance
           [closetime closeindex] = min(abs(posData(:,1)-mintime(qqq)));
           db = closeindex;
           currdist = 0;
           while currdist<30*3.5 & db>0 %finding before 20cm
             currdist = pdist([posData(db,2), posData(db,3); usecenterX, usecenterY]);
             db = db-1;
           end
           da = closeindex;
           currdist = 0;
           while currdist<30*3.5 & db<length(posData) %finding after 20cm
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
           %passtimes = usespos(:,passtimes); %times and positions around current pass
           passspikes1 = find(usespikes>=passstart);
           passspikes2 = find(usespikes<=passend);
           passspikes = intersect(passspikes1, passspikes2); %spike indices windows
           passspikes = sort(usespikes(passspikes)); %actual spikes times in window

            if length(passspikes)>0 %if there are any spikes in the window, assign positions to them

              passpos = assignposOLD(passspikes, posData); %positions assigned to spikes


                currvel = assignvelOLD(passspikes, vel);
                currvel = currvel(1:size(passpos,1));
                if qqq==1
                  goodfield(1:length(currvel),:,(end)) = [passpos, currvel'];
                else
                  goodfield(1:length(currvel),:,(end+1)) = [passpos, currvel'];
                end
                mindistall =  [mindistall; mintime(qqq), mindist(qqq)./3.5];


                numpass = numpass+1;
            end
          end


            %passdist = [];
            % for xxx=1:size(passpos,1)
            %  passdist(end+1) = pdist([passpos(xxx,2), passpos(xxx,3); usecenterX, usecenterY]); %distance from points to center of field
            %end

            %if length(passdist>2)

              %endfield = min(find(passdist(minspikeindex:end)>=20)); %20cm after
              %startfield = max(find(passdist(1:minspikeindex)>=20)); %20cm before

            %  currvel = assignvelOLD(passspikes(startfield:endfield), vel);
            %  goodfield(1:length(currvel),:,qqq) = [passpos(startfield:endfield,:), currvel'];


              %[pks,maxlocs] = findpeaks(passdist);
              %maxlocs = [1,maxlocs,length(passdist)];
              %peakabove = find(maxlocs>minspikeindex); %peaks above closest
              %peakbelow = find(maxlocs<minspikeindex);
              %peakabove = min(peakabove); %index in maxlocs
              %peakbelow = max(peakbelow);
              %distpeakabove = passdist(maxlocs(peakabove)); %distance value
              %distpeakbelow = passdist(maxlocs(peakbelow));
              %currvel = assignvelOLD(passspikes(maxlocs(peakbelow):maxlocs(peakabove)), vel);
              %goodfield(1:length(currvel),:,qqq) = [passpos(maxlocs(peakbelow):maxlocs(peakabove),:), currvel'];
          %  else
            %  goodfield(1,:,qqq) = NaN
          %  end


            %have to translate above into spike indices



              %if abs(passdist)<=30*3.5 %radius of place field + 10cm buffer
              %    currvel = assignvelOLD(passpos(xxx,1), vel);
              %      goodfield(nummy,:,qqq) = [passpos(xxx,:), currvel];
              %      nummy=nummy+1;
              %  end


          %  end
          end
          end

          goodfield(goodfield==0) = NaN;

          title = strcat(char(fieldname),'_');
          title = strcat(title, char(num2str(z)));
          allfields.(title) = goodfield;

test = test+size(goodfield,3);
if size(mindistall,1)~=test
  mindistall =  [mindistall;NaN, NaN];
end

end


  f = allfields;
mindistall;
