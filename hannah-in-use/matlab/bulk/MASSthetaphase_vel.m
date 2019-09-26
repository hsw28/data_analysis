function [f notes] = MASSthetaphase_vel(structureofspikes, posstructure, timestructure, lfpstructure)
  %unfilted LFP

  %finds theta phase for forced arms versus velbin3 versus reward arms vs choice points




spikenames = fieldnames(structureofspikes);
spikenum = length(spikenames);

output = {'cluster name'; 'length'; 'velbin1 kappa'; 'velbin2'; 'velbin3'; 'velbin4'; 'velbin5'; 'velbin6'};
%output = {'cluster name'; 'length'; 'velbin1 kappa'; 'velbin3'; 'velbin4'};

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
        [velbin1, velbin2, velbin3, velbin4, velbin5, velbin6] = velbintimes(currentpos, rippletimes);
        %[velbin1, velbin2, velbin3, velbin4, velbin5] = posquadbin(currentpos, rippletimes);

      end

      if length(currentlfp)~=length(currenttime)
        warning('your time must be same as your lfp')
      end



      velbin1kappa = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      while z<=length(velbin1)
          [cc indexmin] = min(abs(velbin1(z)-currenttime));
          [cc indexmax] = min(abs(velbin1(z+1)-currenttime));
          newlfp = [newlfp; currentlfp(indexmin:indexmax)];
          newtime = [newtime, currenttime(indexmin:indexmax)];

          [cc indexmin] = min(abs(velbin1(z)-currentcluster));
          [cc indexmax] = min(abs(velbin1(z+1)-currentcluster));
          if length(currentcluster)>=1
          newcluster = [newcluster; currentcluster(indexmin:indexmax)];
          end

          z = z+2;
      end

      if length(newlfp)>2000 & length(newcluster)>12
      velbin1kappa(end+1) = spikethetaphase(newcluster, newlfp, newtime, 1);
      else
        velbin1kappa(end+1) = NaN;
      end
      numpoint(end+1) = length(newcluster);
      allcaps(end+1) = velbin1kappa(end);


%%%%%%%%%%%%


      %now away from reward
      velbin2kappa = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      while z<=length(velbin2)
          [cc indexmin] = min(abs(velbin2(z)-currenttime));
          [cc indexmax] = min(abs(velbin2(z+1)-currenttime));
          newlfp = [newlfp; currentlfp(indexmin:indexmax)];
          newtime = [newtime, currenttime(indexmin:indexmax)];

          [cc indexmin] = min(abs(velbin2(z)-currentcluster));
          [cc indexmax] = min(abs(velbin2(z+1)-currentcluster));
          if length(currentcluster)>=1
          newcluster = [newcluster; currentcluster(indexmin:indexmax)];
          end

          z = z+2;
      end

      if length(newlfp)>2000 & length(newcluster)>8
      velbin2kappa(end+1) = spikethetaphase(newcluster, newlfp, newtime,1);
      else
      velbin2kappa(end+1) = NaN;
      end
      numpoint(end+1) = length(newcluster);
      allcaps(end+1) =velbin2kappa(end);

%%%%%%%%%%%%

%now away from reward
velbin3kappa = [];
z=1;
newlfp = [];
newtime = [];
newcluster = [];
while z<=length(velbin3)
    [cc indexmin] = min(abs(velbin3(z)-currenttime));
    [cc indexmax] = min(abs(velbin3(z+1)-currenttime));
    newlfp = [newlfp; currentlfp(indexmin:indexmax)];
    newtime = [newtime, currenttime(indexmin:indexmax)];

    [cc indexmin] = min(abs(velbin3(z)-currentcluster));
    [cc indexmax] = min(abs(velbin3(z+1)-currentcluster));
    if length(currentcluster)>=1
    newcluster = [newcluster; currentcluster(indexmin:indexmax)];
    end

    z = z+2;
end

if length(newlfp)>2000 & length(newcluster)>8
velbin3kappa(end+1) = spikethetaphase(newcluster, newlfp, newtime,1);
else
velbin3kappa(end+1) = NaN;
end
numpoint(end+1) = length(newcluster);
allcaps(end+1) =velbin3kappa(end);

%%%%%%%%%%%%
%now away from reward
velbin4kappa = [];
z=1;
newlfp = [];
newtime = [];
newcluster = [];
while z<=length(velbin4)
    [cc indexmin] = min(abs(velbin4(z)-currenttime));
    [cc indexmax] = min(abs(velbin4(z+1)-currenttime));
    newlfp = [newlfp; currentlfp(indexmin:indexmax)];
    newtime = [newtime, currenttime(indexmin:indexmax)];

    [cc indexmin] = min(abs(velbin4(z)-currentcluster));
    [cc indexmax] = min(abs(velbin4(z+1)-currentcluster));
    if length(currentcluster)>=1
    newcluster = [newcluster; currentcluster(indexmin:indexmax)];
    end

    z = z+2;
end

if length(newlfp)>2000 & length(newcluster)>8
velbin4kappa(end+1) = spikethetaphase(newcluster, newlfp, newtime,1);
else
velbin4kappa(end+1) = NaN;
end
numpoint(end+1) = length(newcluster);
allcaps(end+1) =velbin4kappa(end);

%%%%%%%%%%%%
%now away from reward

velbin6kappa = [];
z=1;
newlfp = [];
newtime = [];
newcluster = [];
while z<=length(velbin6)
    [cc indexmin] = min(abs(velbin6(z)-currenttime));
    [cc indexmax] = min(abs(velbin6(z+1)-currenttime));
    newlfp = [newlfp; currentlfp(indexmin:indexmax)];
    newtime = [newtime, currenttime(indexmin:indexmax)];

    [cc indexmin] = min(abs(velbin6(z)-currentcluster));
    [cc indexmax] = min(abs(velbin6(z+1)-currentcluster));
    if length(currentcluster)>=1
    newcluster = [newcluster; currentcluster(indexmin:indexmax)];
    end

    z = z+2;
end

if length(newlfp)>2000 & length(newcluster)>8
velbin6kappa(end+1) = spikethetaphase(newcluster, newlfp, newtime,1);
else
velbin6kappa(end+1) = NaN;
end
numpoint(end+1) = length(newcluster);
allcaps(end+1) =velbin6kappa(end);

%%%%%%%%%%%%

%%%%%%%%%%%%
%now away from reward

velbin5kappa = [];
z=1;
newlfp = [];
newtime = [];
newcluster = [];
while z<=length(velbin5)
    [cc indexmin] = min(abs(velbin5(z)-currenttime));
    [cc indexmax] = min(abs(velbin5(z+1)-currenttime));
    newlfp = [newlfp; currentlfp(indexmin:indexmax)];
    newtime = [newtime, currenttime(indexmin:indexmax)];

    [cc indexmin] = min(abs(velbin5(z)-currentcluster));
    [cc indexmax] = min(abs(velbin5(z+1)-currentcluster));
    if length(currentcluster)>=1
    newcluster = [newcluster; currentcluster(indexmin:indexmax)];
    end

    z = z+2;
end

if length(newlfp)>2000 & length(newcluster)>8
velbin5kappa(end+1) = spikethetaphase(newcluster, newlfp, newtime,1);
else
velbin5kappa(end+1) = NaN;
end
numpoint(end+1) = length(newcluster);
allcaps(end+1) =velbin5kappa(end);
%%%%

      newdata = {name; length(currentcluster); velbin1kappa; velbin2kappa; velbin3kappa; velbin4kappa; velbin5kappa; velbin6kappa};
%      newdata = {name; length(currentcluster); velbin1kappa; velbin3kappa; velbin4kappa};

      output = horzcat(output, newdata);

previousdate =  newdate;
  end

  f = output';
    save('kappa_vel.mat','f')
  notes = [numpoint; allcaps];
