function f  = MASSvelocity_mid3(posstructure, timestructure, lfpstructure)
%finds velocities for three middle segments
  %unfilted LFP
  %finds theta phase for forced arms versus toreward2 versus reward arms vs choice points




posnames = fieldnames(posstructure);
posnum = length(posnames)

output = {'name'; 'toreward1 vel'; 'awayreward1'; 'toreward2'; 'awayreward2'; 'toreward3'; 'awayreward3'};
%output = {'cluster name'; 'length'; 'toreward1 kappa'; 'toreward2'; 'awayreward2'};

numpoint = [];
allcaps =[];
previousdate = 0;
maxcc = [];
k = 2;
while k<=posnum
  k
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
      [toreward1, awayreward1, toreward2, awayreward2, toreward3, awayreward3] = middletimes3(currentpos);

      toreward1vel = [];
      z=1;
      newvel = [];
      while z<=length(toreward1)
          [cc indexmin] = min(abs(toreward1(z)-veltime));
          [cc indexmax] = min(abs(toreward1(z+1)-veltime));
          newvel = [newvel; vel(indexmin:indexmax)'];
          z = z+2;
      end
      if length(newvel)>15
      toreward1vel(end+1) = nanmean(newvel);
      end

%%%%%%%%%%%%

      %now away from reward
      awayreward1vel = [];
      z=1;
      newvel = [];
      while z<=length(awayreward1)
          [cc indexmin] = min(abs(awayreward1(z)-veltime));
          [cc indexmax] = min(abs(awayreward1(z+1)-veltime));
          newvel = [newvel; vel(indexmin:indexmax)'];
          z = z+2;
      end
      if length(newvel)>15
      awayreward1vel(end+1) = nanmean(newvel);
      end

%%%%%%%%%%%%

%now away from reward
toreward2vel = [];
z=1;
newvel = [];
while z<=length(toreward2)
    [cc indexmin] = min(abs(toreward2(z)-veltime));
    [cc indexmax] = min(abs(toreward2(z+1)-veltime));
    newvel = [newvel; vel(indexmin:indexmax)'];
    z = z+2;
end
if length(newvel)>15
toreward2vel(end+1) = nanmean(newvel);
end

%%%%%%%%%%%%
awayreward2vel = [];
z=1;
newvel = [];
while z<=length(awayreward2)
    [cc indexmin] = min(abs(awayreward2(z)-veltime));
    [cc indexmax] = min(abs(awayreward2(z+1)-veltime));
    newvel = [newvel; vel(indexmin:indexmax)'];
    z = z+2;
end
if length(newvel)>15
awayreward2vel(end+1) = nanmean(newvel);
end

%%%%%%%%%%%%
%now away from reward

toreward3vel = [];
z=1;
newvel = [];
while z<=length(toreward3)
    [cc indexmin] = min(abs(toreward3(z)-veltime));
    [cc indexmax] = min(abs(toreward3(z+1)-veltime));
    newvel = [newvel; vel(indexmin:indexmax)'];
    z = z+2;
end
if length(newvel)>15
toreward3vel(end+1) = nanmean(newvel);
end

%%%%%%%%%%%%
awayreward3vel = [];
z=1;
newvel = [];
while z<=length(awayreward3)
    [cc indexmin] = min(abs(awayreward3(z)-veltime));
    [cc indexmax] = min(abs(awayreward3(z+1)-veltime));
    newvel = [newvel; vel(indexmin:indexmax)'];
    z = z+2;
end
if length(newvel)>15
awayreward3vel(end+1) = nanmean(newvel);
end


      newdata = {name; toreward1vel; awayreward1vel; toreward2vel; awayreward2vel; toreward3vel; awayreward3vel};
%      newdata = {name; length(currentcluster); toreward1kappa; toreward2kappa; awayreward2kappa};

      output = horzcat(output, newdata);


k = k+3;
  end

  f = output';
