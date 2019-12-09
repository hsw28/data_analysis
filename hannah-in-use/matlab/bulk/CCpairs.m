function [f fnot] = CCpairs(fieldchartHPC_dir, fieldchartLS_dir, HPCclusters, LSclusters, posstructure)
%if lag is positive, then Y is delayed relative to x
test = 0;

figure
HPCfieldchart = fieldchartHPC_dir(2:end, :);
LSfieldchart = fieldchartLS_dir(2:end, :);
HPCfieldnames = (HPCfieldchart(:,1));
LSfieldnames = (LSfieldchart(:,1));
LSnums = [1:1:length(LSfieldnames)];

HPCclustnames = (fieldnames(HPCclusters));
HPCclustnum = length(HPCclustnames);
LSclustnames = (fieldnames(LSclusters));
LSclustnum = length(LSclustnames);

posnames = (fieldnames(posstructure));
posnum = length(posnames);
pnames = {};
for s = 1:posnum
  if contains(posnames(s), 'position')==1
    pnames(end+1) = (posnames(s));
  end
end

quad = [];
dir = [];
allaverage = [];
minusaverage = [];
plusaverage = [];
maxes = [];
Xes = [];
Yes = [];
notallaverage = [];
notminusaverage = [];
notplusaverage = [];
notmaxes = [];
maxtime = [];
allcors = [];
for q = 1:length(pnames)
  currentname = char(pnames(q));
  posData = posstructure.(currentname);
  posData = fixpos(posData); %positions, not sure if needed
  posTime = posData(:,1);
  % get date of spike
  date = strsplit(currentname,'date_'); %splitting at year rat12_2018_08_20_time
  date = char(date(1,2));
  date = strsplit(date,'_position'); %rat12_2018_08_20
  date = char(date(1,1));


  %ELIGILE HPC
  HPCcurrentclusts = struct;
  for c = 1:length(HPCclustnum)
    name = char(HPCclustnames(c));
    if contains(name, date)==1
      [HPCcurrentclusts(:).(name)] = deal(HPCclusters.(name)); %allpossible HPC clusters
    end
  end
  currentHPCfields = [];
  for c = 1:length(HPCfieldnames)
    name = char(HPCfieldnames(c));
    if contains(name, date)==1
      currentHPCfields = [currentHPCfields; HPCfieldchart(c,:)]; %all possible HPC place fields
    end
  end

    %ELIGILE LS
    LScurrentclusts = struct;
    for c = 1:length(LSclustnum)
      name = char(LSclustnames(c));
      if contains(name, date)==1
        [LScurrentclusts(:).(name)] = deal(LSclusters.(name)); %allpossible LS clusters
      end
    end
    currentLSfields = [];
    for c = 1:length(LSfieldnames)
      name = char(LSfieldnames(c));
      if contains(name, date)==1
        currentLSfields = [currentLSfields; LSfieldchart(c,:)]; %all possible HPC place fields
      end
    end


for k = 1:size(currentHPCfields,1) %going through HPC pairs
  currentdir = cell2mat(currentHPCfields(k,4));
  currentxHPC = cell2mat(currentHPCfields(k,6));
  currentyHPC = cell2mat(currentHPCfields(k,7));
  Xes(end+1) = currentxHPC;
  Yes(end+1) = currentyHPC;
  currentavrateHPC = cell2mat(currentHPCfields(k,10));

  LSuse = LSnums;
  LSuse = find(cell2mat(currentLSfields(:,4)) == currentdir); %finding LS fields in same direction
  %LSuse = intersect(LSuse, LSnums); %make sure cell hasn't been used before

  potentialLS = [];
  notpotentialLS = [];

  for z = 1:length(LSuse)
    currentindex = LSuse(z);
    currentxLS = cell2mat(currentLSfields(currentindex,6));
    currentyLS = cell2mat(currentLSfields(currentindex,7));
    dis = pdist([currentxHPC,currentyHPC;currentxLS,currentyLS], 'euclidean'); %distance between centers
    if dis <= 3.5*20 %if distance is less than 16cm, save index
      potentialLS(end+1) = currentindex;
    end
    if dis >= 3.5*100 %if distance is less than 16cm, save index
      notpotentialLS(end+1) = currentindex;
    end
  end

  %FOR GOOD MATCHES
  if length(potentialLS)>=1
  %now for potential indices, match rate
  allpotentialLSrates = cell2mat(currentLSfields(potentialLS,10));
  [minValue,closestIndex] = min(abs(currentavrateHPC-allpotentialLSrates));
  LSpairindex = potentialLS(closestIndex); %this is the index of the match

  %subtract the index of the match out of future potential matches
  %LSnums = LSnums(find(LSnums ~= LSpairindex));


  clusternameHPC = char(currentHPCfields(k,1)); %INDLUDE
  clusternameLS = char(currentLSfields(LSpairindex, 1)); %INDLUDE
      currentxLS = cell2mat(currentLSfields(LSpairindex,6));
      currentyLS = cell2mat(currentLSfields(LSpairindex,7));

  DIRECTION = currentdir; %INDLUDE
  DISTANCEBETWEEN = pdist([currentxHPC, currentyHPC; currentxLS, currentyLS]); %INDLUDE



  %NEED TO GET DISTANCE FROM REWARD OR AT LEAST QUADRANT HERE

  %maybe put in some criteria for position here??? dont know. not sure we want crosscorr along whole track
  %now you have the pair, so have to find crosscorr.
  %go back and get the correct clusters
  currentHPCclust = HPCclusters.(clusternameHPC);
  currentLSclust = LSclusters.(clusternameLS);

  HPCtrain = spiketrain(currentHPCclust, posTime, .01);
  LStrain = spiketrain(currentLSclust, posTime, .01);
  [CC,lags,bounds] = crosscorr(HPCtrain, LStrain, 'NumLags', .1/.01); %bins are 10ms, so 100ms is 10 on each side

test = test+1;

  allcors = [allcors, CC];



  allaverage(end+1) = nanmean(CC);
  minusaverage(end+1) = nanmean(CC(1:10));
  plusaverage(end+1) = nanmean(CC(10:end));
  [Y,I] = max(CC);
  maxes(end+1) = Y;
  maxtime(end+1) = lags(I)*.01;
  dir(end+1) = currentdir;

  CCshuffled = crosscorr(HPCtrain, LStrain(randperm(length(LStrain))), 'NumLags', .1/.01); %bins are 10ms, so 100ms is 10 on each side
  notallaverage(end+1) = nanmean(CCshuffled);
  notminusaverage(end+1) = nanmean(CCshuffled(1:10));
  notplusaverage(end+1) = nanmean(CCshuffled(10:end));
  notmaxes(end+1) = max(CCshuffled);



%no close matches
else
    test = test+1;
  dir(end+1) = NaN;
  allaverage(end+1) = NaN;
  minusaverage(end+1) = NaN;
  plusaverage(end+1) = NaN;
  maxes(end+1) = NaN;
  notallaverage(end+1) = NaN;
  notminusaverage(end+1) = NaN;
  notplusaverage(end+1) = NaN;
  notmaxes(end+1) = NaN;
  maxtime(end+1) = NaN;
  allcors = [allcors, NaN(21,1)];

end %this end is for no close matches



end %this end is for going through hpc pairs
end %this end is for the for loop going through positions

posQuadmax = NaN(length(Xes),1);


xlimmin = [300 300 320 320 320 450 750 780 828 780 780];
xlimmax = [505 450 450 505 505 850 950 950 950 950 950];
ylimmin = [545 422 320 170 000 300 575 420 339 182 000];
ylimmax = [700 545 422 320 170 440 700 575 420 339 182];
for k=1:length(xlimmin)
  inX = find(Xes > xlimmin(k) & Xes <=xlimmax(k));
  inY = find(Yes > ylimmin(k) & Yes <=ylimmax(k));
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


val = ~isnan(dir);


f = [dir(val); allaverage(val); minusaverage(val); plusaverage(val); maxes(val); posQuadmax(val)'; maxtime(val)]';

fnot = [dir(val); notallaverage(val); notminusaverage(val); notplusaverage(val); notmaxes(val); posQuadmax(val)']';

allcors = allcors(:,val);
Pos0 = find(f(:,6)==0);
Pos1 = find(f(:,6)==1);
Pos2 = find(f(:,6)==2);
Pos3 = find(f(:,6)==3);
Pos4 = find(f(:,6)==4);
Pos5 = find(f(:,6)==5);
Pos6 = find(f(:,6)==6);

%figure
%plot(-100:10:100, nanmean((allcors(:,[Pos0;Pos1]))'))
%hold on
%plot(-100:10:100,nanmean((allcors(:,[Pos3]))'))
%plot(-100:10:100, nanmean((allcors(:,[Pos5; Pos6]))'))

figure
errorbar(-100:10:100, nanmean((allcors(:,[Pos0;Pos1]))'), std((allcors(:,[Pos0;Pos1]))')./sqrt(length([Pos0;Pos1])), 'Color', 'red');
hold on
errorbar(-100:10:100,nanmean((allcors(:,[Pos3]))'), std((allcors(:,[Pos3]))')./sqrt(length([Pos3])), 'Color', 'green');
errorbar(-100:10:100, nanmean((allcors(:,[Pos5; Pos6]))'), std((allcors(:,[Pos5; Pos6]))')./sqrt(length([Pos5;Pos6])), 'Color','blue');





%output distance from reward, distance from eachother, and cross corr all, +100, and -100, max
