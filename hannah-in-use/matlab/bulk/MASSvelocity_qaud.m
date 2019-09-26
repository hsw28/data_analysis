function f  = MASSvelocity_qaud(posstructure, timestructure, lfpstructure)
  %unfilted LFP
  %finds velocities for the different quadrans



posnames = fieldnames(posstructure);
posnum = length(posnames)

output = {'name'; 'forcedarms vel'; 'forcedpoint'; 'middle'; 'choicearms'; 'freepoint'};
%output = {'cluster name'; 'length'; 'forcedarms kappa'; 'middle'; 'choicearms'};

numpoint = [];
allcaps =[];
previousdate = 0;
maxcc = [];
k = 2;
while k<=posnum
    name = char(posnames(k));
    currentvel = posstructure.(name);
    veltime = currentvel(2,:);
    vel = currentvel(1,:);
    % get date of spike
    date = strsplit(name,'_vel');
    date = char(date(1,1))
    date = strsplit(date,'_maze_cl');
    date = char(date(1,1));
    date = strsplit(date,'_box_cl');
    date = char(date(1,1));
    date = strsplit(date,'_rotation_cl');
    date = char(date(1,1));
    date = strsplit(date,'_cl');
    date = char(date(1,1));



      % formats date to be same as in position structure: date_2015_08_01_acc
      velformateddate = strcat(date, '_vel');
      %velformateddate = strcat('date_', velformateddate);
      % formats date to be same as in time structure: date_2015_08_01_time
      timeformateddate = strcat(date, '_time');
      %timeformateddate = strcat('date_', timeformateddate);
      % formats date to be same as in time structure: date_2015_08_01_position
      posformateddate = strcat(date, '_position');
      %posformateddate = strcat('date_', posformateddate);
      % formats lfp to be same as in lfp structure: date_2015_08_01_position
      lfpformateddate = strcat(date, '_lfp');
      %lfpformateddate = strcat('date_', lfpformateddate);

      %newdatechar = date;
      %newdate = {date};
      %newdate = char(strrep(newdate,'_',''));
      %newdate = strsplit(newdate,'rat');
      %newdate = char(newdate(1,2));
      %newdate = str2num(newdate);

      currentpos = posstructure.(posformateddate);
      currenttime = timestructure.(timeformateddate);
      if isfield(lfpstructure, lfpformateddate)==1
        fprintf('lfp found :D')
        currentlfp = lfpstructure.(lfpformateddate);
        unfilteredLFP = lfpstructure.(lfpformateddate);
      else
        fprintf('no lfp found :(')
        k = k+3;
        continue
      end



      [rippletimes, all] = findripLFP(unfilteredLFP, currenttime, 2.5, velocity(currentpos));
      currentlfp = thetafilt412(currentlfp);
      [forcedarms, forcedpoint, middle, choicearms, freepoint] = posquadbin(currentpos, rippletimes);


      forcedarmsvel = [];
      z=1;
      newvel = [];
      while z<=length(forcedarms)
          [cc indexmin] = min(abs(forcedarms(z)-veltime));
          [cc indexmax] = min(abs(forcedarms(z+1)-veltime));
          newvel = [newvel; vel(indexmin:indexmax)'];
          z = z+2;
      end
      if length(newvel)>15
      forcedarmsvel(end+1) = nanmean(newvel);
      end

%%%%%%%%%%%%

      %now away from reward
      forcedpointvel = [];
      z=1;
      newvel = [];
      while z<=length(forcedpoint)
          [cc indexmin] = min(abs(forcedpoint(z)-veltime));
          [cc indexmax] = min(abs(forcedpoint(z+1)-veltime));
          newvel = [newvel; vel(indexmin:indexmax)'];
          z = z+2;
      end
      if length(newvel)>15
      forcedpointvel(end+1) = nanmean(newvel);
      end

%%%%%%%%%%%%

%now away from reward
middlevel = [];
z=1;
newvel = [];
while z<=length(middle)
    [cc indexmin] = min(abs(middle(z)-veltime));
    [cc indexmax] = min(abs(middle(z+1)-veltime));
    newvel = [newvel; vel(indexmin:indexmax)'];
    z = z+2;
end
if length(newvel)>15
middlevel(end+1) = nanmean(newvel);
end

%%%%%%%%%%%%
choicearmsvel = [];
z=1;
newvel = [];
while z<=length(choicearms)
    [cc indexmin] = min(abs(choicearms(z)-veltime));
    [cc indexmax] = min(abs(choicearms(z+1)-veltime));
    newvel = [newvel; vel(indexmin:indexmax)'];
    z = z+2;
end
if length(newvel)>15
choicearmsvel(end+1) = nanmean(newvel);
end

%%%%%%%%%%%%
%now away from reward

freepointvel = [];
z=1;
newvel = [];
while z<=length(freepoint)
    [cc indexmin] = min(abs(freepoint(z)-veltime));
    [cc indexmax] = min(abs(freepoint(z+1)-veltime));
    newvel = [newvel; vel(indexmin:indexmax)'];
    z = z+2;
end
if length(newvel)>15
freepointvel(end+1) = nanmean(newvel);
end

%%%%%%%%%%%%

      newdata = {name; forcedarmsvel; forcedpointvel; middlevel; choicearmsvel; freepointvel};
%      newdata = {name; length(currentcluster); forcedarmskappa; middlekappa; choicearmskappa};

      output = horzcat(output, newdata);


k = k+3;
  end

  f = output';
