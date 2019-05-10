function [f notes] = MASSthetaphase_quad(structureofspikes, posstructure, timestructure, lfpstructure)
  %unfilted LFP
  %finds theta phase for forced arms versus middle versus reward arms vs choice points




spikenames = fieldnames(structureofspikes);
spikenum = length(spikenames);

output = {'cluster name'; 'length'; 'forcedarms kappa'; 'forcedpoint'; 'middle'; 'choicearms'; 'freepoint'};
%output = {'cluster name'; 'length'; 'forcedarms kappa'; 'middle'; 'choicearms'};

numpoint = [];
allcaps =[];
previousdate = 0;
maxcc = [];
for k=1:spikenum
    name = char(spikenames(k))
    currentcluster = structureofspikes.(name);
    % get date of spike
    date = strsplit(name,'cluster_'); %splitting at year
    date = char(date(1,2));
    date = strsplit(date,'_maze_cl');
    date = char(date(1,1));
    date = strsplit(date,'_box_cl');
    date = char(date(1,1));
    date = strsplit(date,'_rotation_cl');
    date = char(date(1,1));
    date = strsplit(date,'_cl');
    date = char(date(1,1));
    date = strcat(date, '!');
    date = regexp(date,'_1!|_2!|_3!|_4!|_5!|_6!|_7!|_8!|_9!|_10!|_11!|_12!|_13!|_14!|_15!|_16!|_17!|_18!|_19!|_20!|_21!|_22!|_23!|_24!|_25!|_26!|_27!|_28!|_29!|_30!|_31!|_32!','split');
    %date = strsplit(date,'_1!'|'_2!'|'_3!','_4!','_5!','_6!','_7!','_8!','_9!','_10!','_11!','_12!','_13!','_14!','_15!','_16!','_17!','_18!','_19!','_20!','_21!','_22!','_23!','_24!', '_25!', '_26!', '_27!', '_28!', '_29!', '_30!', '_31!', '_32!')
    date = char(date(1,1));

      %date = regexp(date,'(?=[maze])_1_|_2_|_3_|_4_|_5_|_6_|_7_|_8_|_9_|_10_|_11_|_12_|_13_|_14_|_15_|_16_|_17_|_18_|_19_|_20_|_21_|_22_|_23_|_24_|_25_|_26_|_27_|_28_|_29_|_30_|_31_|_32_','split');
      %date = char(date(1,1));
      % formats date to be same as in position structure: date_2015_08_01_acc
      velformateddate = strcat(date, '_vel');
      velformateddate = strcat('date_', velformateddate);
      % formats date to be same as in time structure: date_2015_08_01_time
      timeformateddate = strcat(date, '_time');
      timeformateddate = strcat('date_', timeformateddate);
      % formats date to be same as in time structure: date_2015_08_01_position
      posformateddate = strcat(date, '_position');
      posformateddate = strcat('date_', posformateddate);
      % formats lfp to be same as in lfp structure: date_2015_08_01_position
      lfpformateddate = strcat(date, '_lfp');
      lfpformateddate = strcat('date_', lfpformateddate);

      newdatechar = date;
      newdate = {date};
      newdate = char(strrep(newdate,'_',''));
      newdate = strsplit(newdate,'rat');
      newdate = char(newdate(1,2));
      newdate = str2num(newdate);

      currentpos = posstructure.(posformateddate);
      currentlfp = lfpstructure.(lfpformateddate);
      currenttime = timestructure.(timeformateddate);
      currentcluster = structureofspikes.(name);

      if newdate ~= previousdate
        unfilteredLFP = currentlfp;
        [rippletimes, all] = findripLFP(unfilteredLFP, currenttime, 2.5, velocity(currentpos));
        currentlfp = thetafilt412(currentlfp);
        [forcedarms, forcedpoint, middle, choicearms, freepoint] = posquadbin(currentpos, rippletimes);

      end

      if length(currentlfp)~=length(currenttime)
        warning('your time must be same as your lfp')
      end



      forcedarmskappa = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      while z<=length(forcedarms)
          [cc indexmin] = min(abs(forcedarms(z)-currenttime));
          [cc indexmax] = min(abs(forcedarms(z+1)-currenttime));
          newlfp = [newlfp; currentlfp(indexmin:indexmax)];
          newtime = [newtime, currenttime(indexmin:indexmax)];

          [cc indexmin] = min(abs(forcedarms(z)-currentcluster));
          [cc indexmax] = min(abs(forcedarms(z+1)-currentcluster));
          if length(currentcluster)>=1
          newcluster = [newcluster; currentcluster(indexmin:indexmax)];
          end

          z = z+2;
      end

      if length(newlfp)>2000 & length(newcluster)>12
      forcedarmskappa(end+1) = spikethetaphase(newcluster, newlfp, newtime, 1);
      else
        forcedarmskappa(end+1) = NaN;
      end
      numpoint(end+1) = length(newcluster);
      allcaps(end+1) = forcedarmskappa(end);


%%%%%%%%%%%%


      %now away from reward
      forcedpointkappa = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      while z<=length(forcedpoint)
          [cc indexmin] = min(abs(forcedpoint(z)-currenttime));
          [cc indexmax] = min(abs(forcedpoint(z+1)-currenttime));
          newlfp = [newlfp; currentlfp(indexmin:indexmax)];
          newtime = [newtime, currenttime(indexmin:indexmax)];

          [cc indexmin] = min(abs(forcedpoint(z)-currentcluster));
          [cc indexmax] = min(abs(forcedpoint(z+1)-currentcluster));
          if length(currentcluster)>=1
          newcluster = [newcluster; currentcluster(indexmin:indexmax)];
          end

          z = z+2;
      end

      if length(newlfp)>2000 & length(newcluster)>8
      forcedpointkappa(end+1) = spikethetaphase(newcluster, newlfp, newtime,1);
      else
      forcedpointkappa(end+1) = NaN;
      end
      numpoint(end+1) = length(newcluster);
      allcaps(end+1) =forcedpointkappa(end);

%%%%%%%%%%%%

%now away from reward
middlekappa = [];
z=1;
newlfp = [];
newtime = [];
newcluster = [];
while z<=length(middle)
    [cc indexmin] = min(abs(middle(z)-currenttime));
    [cc indexmax] = min(abs(middle(z+1)-currenttime));
    newlfp = [newlfp; currentlfp(indexmin:indexmax)];
    newtime = [newtime, currenttime(indexmin:indexmax)];

    [cc indexmin] = min(abs(middle(z)-currentcluster));
    [cc indexmax] = min(abs(middle(z+1)-currentcluster));
    if length(currentcluster)>=1
    newcluster = [newcluster; currentcluster(indexmin:indexmax)];
    end

    z = z+2;
end

if length(newlfp)>2000 & length(newcluster)>8
middlekappa(end+1) = spikethetaphase(newcluster, newlfp, newtime,1);
else
middlekappa(end+1) = NaN;
end
numpoint(end+1) = length(newcluster);
allcaps(end+1) =middlekappa(end);

%%%%%%%%%%%%
%now away from reward
choicearmskappa = [];
z=1;
newlfp = [];
newtime = [];
newcluster = [];
while z<=length(choicearms)
    [cc indexmin] = min(abs(choicearms(z)-currenttime));
    [cc indexmax] = min(abs(choicearms(z+1)-currenttime));
    newlfp = [newlfp; currentlfp(indexmin:indexmax)];
    newtime = [newtime, currenttime(indexmin:indexmax)];

    [cc indexmin] = min(abs(choicearms(z)-currentcluster));
    [cc indexmax] = min(abs(choicearms(z+1)-currentcluster));
    if length(currentcluster)>=1
    newcluster = [newcluster; currentcluster(indexmin:indexmax)];
    end

    z = z+2;
end

if length(newlfp)>2000 & length(newcluster)>8
choicearmskappa(end+1) = spikethetaphase(newcluster, newlfp, newtime,1);
else
choicearmskappa(end+1) = NaN;
end
numpoint(end+1) = length(newcluster);
allcaps(end+1) =choicearmskappa(end);

%%%%%%%%%%%%
%now away from reward

freepointkappa = [];
z=1;
newlfp = [];
newtime = [];
newcluster = [];
while z<=length(freepoint)
    [cc indexmin] = min(abs(freepoint(z)-currenttime));
    [cc indexmax] = min(abs(freepoint(z+1)-currenttime));
    newlfp = [newlfp; currentlfp(indexmin:indexmax)];
    newtime = [newtime, currenttime(indexmin:indexmax)];

    [cc indexmin] = min(abs(freepoint(z)-currentcluster));
    [cc indexmax] = min(abs(freepoint(z+1)-currentcluster));
    if length(currentcluster)>=1
    newcluster = [newcluster; currentcluster(indexmin:indexmax)];
    end

    z = z+2;
end

if length(newlfp)>2000 & length(newcluster)>8
freepointkappa(end+1) = spikethetaphase(newcluster, newlfp, newtime,1);
else
freepointkappa(end+1) = NaN;
end
numpoint(end+1) = length(newcluster);
allcaps(end+1) =freepointkappa(end);

%%%%%%%%%%%%

      newdata = {name; length(currentcluster); forcedarmskappa; forcedpointkappa; middlekappa; choicearmskappa; freepointkappa};
%      newdata = {name; length(currentcluster); forcedarmskappa; middlekappa; choicearmskappa};

      output = horzcat(output, newdata);

previousdate =  newdate;
  end

  f = output';
  notes = [numpoint; allcaps];
