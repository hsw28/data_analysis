function f = MASSplacefieldnumDIRECTIONALtrials(clusters,posstructure, dim, fieldchart)
  %fieldchart is output from MASSplacefieldnumDIRECTIONAL

      %set(0,'DefaultFigureVisible', 'off');

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

posnames = (fieldnames(posstructure));
posnum = length(posnames);
pnames = {};
for s = 1:posnum
  if contains(posnames(s), 'position')==1
    pnames(end+1) = (posnames(s));
  end
end

%output = {'cluster name'; 'cluster size'; 'direction'; 'num of fields'; 'field size in cm'; 'centermax'; 'centermean'; 'skewness'};
output = {'cluster name'; 'cluster size'; 'direction'; '1=to, 2=away'; 'field size in cm'; 'centermax X'; 'centermax Y'; 'skewness'; 'dir skewness'; 'av field rate'; 'max field rate'};

for z = 1:length(pnames)
  currentname = char(pnames(z))
  posData = posstructure.(currentname);
  posData = fixpos(posData);
  % get date of spike
  date = strsplit(currentname,'date_'); %splitting at year rat12_2018_08_20_time
  date = char(date(1,2));
  date = strsplit(date,'_position'); %rat12_2018_08_20
  date = char(date(1,1));

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

%Sum of (occprobs * mean firing rate per bin / meanrate) * log2 (mean firing rate per bin / meanrate)

%spike rates


for c = 1:(currentnumclust)
  name = char(currentclustname(c));
    clust = currentclusts.(name);
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




      %finding number of place fields
      fields = [];
      for zz = 1:size(fieldchart,1)
        if contains(fieldchart(zz,1), name) == 1
        fields(end+1) = zz; %making list of indices that apply to the cluster to find fields
      end
      end

      for q=1:length(fields) %going through the fields
        if cell2mat(fieldchart(fields(q),4)) == 1 %towards reward
          usespikes = torewardspikes;
          usespos = torewardpos;
        else
          usespikes = awayrewardspikes;
          usespos = awayrewardpos;
        end

        usecenterX = cell2mat(fieldchart(fields(q),6));
        usecenterY = cell2mat(fieldchart(fields(q),7));
        usecentersize = cell2mat(fieldchart(fields(q),5));

        %want to find every time animal passed through field going the correct direction
        %all positions in question: usespos
        %all spikes in question: usespikes


        disty = [];
        for qq = 1:size(usespos,2)
        disty(end+1) = pdist([usecenterX, usecenterY; usespos(2,qq), usespos(3,qq)]); %finds distance to center
        end
        %ld = length(disty) %%%HERE%%%

        distyclose = find((disty)<(7*3.5));
        distyclose = usespos(1,distyclose); %times close to field
        %divide times by lap
        %ldc = length(distyclose)  %%%HERE%%%

        %find spiking in 2 second increments
        %diff does second minus first
        differences = abs(diff(distyclose));
        newpass = 1;
        newpass = [newpass, find(differences > usecentersize*1.5/10+2)]; %if more than two seconds apart, a different pass
        %NEW PASS IS THE INDICES FOR EACH NEW PASS, FROM DISTY, NOT TIMES OR POSITIONS

usecenterX;
usecenterY;
        usespos(2,newpass);
        usespos(3,newpass);


        goodfield = NaN(50, 4, length(newpass));
        for qqq=1:length(newpass) %going through passes
           %passtimes = find(abs(usespos(1,:)-usespos(1,newpass(qqq)))<(usecentersize*3.5./10*1.5)); %you get 1.5s for every cm of field size
           if length(newpass)>0
           distyclose(newpass(qqq));
           passstart = distyclose(newpass(qqq)+1)-(usecentersize*1.5/10);
           passend = distyclose(newpass(qqq)+1)+(usecentersize*1.5/10);
           %passtimes = usespos(:,passtimes); %times and positions around current pass
           passspikes1 = find(usespikes>=passstart); %spikes in the second windows
           size(passspikes1);
           passspikes2 = find(usespikes<=passend);
           size(passspikes2);
           passspikes = intersect(passspikes1, passspikes2);
           size(passspikes);
          % length(passspikes)
            if length(passspikes)>0
              spikez = sort(usespikes(passspikes));
              passpos = assignposOLD(spikez, posData); %positions assigned to spikes
              nummy=1;
             for xxx=1:size(passpos,1)
              passdist = pdist([passpos(xxx,2), passpos(xxx,3); usecenterX, usecenterY]); %distance from points to center of field
                if abs(passdist)<=(usecentersize*3.5./2)+(10*3.5) %radius of place field + 10cm buffer
                  currvel = assignvelOLD(passpos(xxx,1), vel);
                  %goodfield(xxx,:,qqq) = [passpos(xxx,:), currvel];
                  [passpos(xxx,:), currvel]
                    goodfield(nummy,:,qqq) = [passpos(xxx,:), currvel];
                    nummy=nummy+1;

                end
              end

            else
            %goodfield(1,:,qqq) = [NaN,NaN,NaN,NaN];
            end
          else
          %goodfield(1,:,qqq) = [NaN,NaN,NaN,NaN];
          end
        %  end
          end

          goodfield(goodfield==0) = NaN;
          %replace = find(goodfield(:,1,:))==0;
          %goodfield(replace) = NaN;
          %test = ~isnan(goodfield(:,1,:));

          %goodfield = goodfield(:,:,test(1,1,:))


          title = strcat(char(name),'_');
          title = strcat(title, char(num2str(q)));
          allfields.(title) = goodfield;
    end
  end
end
end

  f = allfields;
