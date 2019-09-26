function [f allto allaway] = MASSthetaphase_mid2(structureofspikes, posstructure, timestructure, lfpstructure)
  %unfilted LFP
  %combines all times in one direction then finds kappa, DOES find for each trial individually
  %finds kappa for choice versus free in middle arm (directional)




spikenames = fieldnames(structureofspikes);
spikenum = length(spikenames);

%plots = ceil(spikenum./3);
output = {'cluster name'; 'length'; 'mean kappa to reward'; 'mean kappa away from reward'; 'mean phase to'; 'mean phase away'};

numpoint = [];
allcaps =[];
previousdate = 0;
maxcc = [];
allto = [];
allaway = [];
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

      %if newdate ~= previousdate & isfield(timestructure, (timeformateddate))==1 & isfield(posstructure, (posformateddate))==1 & isfield(lfpstructure, (lfpformateddate))==1

      currentpos = posstructure.(posformateddate);
      currentlfp = lfpstructure.(lfpformateddate);
      currenttime = timestructure.(timeformateddate);
      currentcluster = structureofspikes.(name);

      if length(currentlfp)~=length(currenttime)
        warning('your time must be same as your lfp')
      end

      [toreward, awayreward] = middletimes(currentpos, 1);

      torewardkappa = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      meanphasetowards = [];
      devtowards = [];

      while z<=length(toreward)
          [cc indexmin] = min(abs(toreward(z)-currenttime));
          [cc indexmax] = min(abs(toreward(z+1)-currenttime));
          newlfp = currentlfp(indexmin:indexmax);
          newtime = currenttime(indexmin:indexmax);

          [cc indexmin] = min(abs(toreward(z)-currentcluster));
          [cc indexmax] = min(abs(toreward(z+1)-currentcluster));

          newcluster = currentcluster(indexmin:indexmax);

          if length(newlfp)>1000 & length(newcluster)>6 %good with 6
          [torewardkappa(end+1) meanphasetowards(end+1) devtowards(end+1)] = spikethetaphase(newcluster, newlfp, newtime, 0);
          allto(end+1) = torewardkappa(end);
          else
            torewardkappa(end+1) = NaN;
            meanphasetowards(end+1) = NaN;
            devtowards = NaN;
            allto(end+1) = NaN;
          end
          z = z+2;
      end

      torewardkappa = nanmean(torewardkappa);
      meanphasetowards = nanmean(meanphasetowards);


      %now away from reward
      awayrewardkappa = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      meanphaseaway = [];
      devaway = [];

      while z<=length(awayreward)
          [cc indexmin] = min(abs(awayreward(z)-currenttime));
          [cc indexmax] = min(abs(awayreward(z+1)-currenttime));
          newlfp = currentlfp(indexmin:indexmax);
          newtime = currenttime(indexmin:indexmax);

          [cc indexmin] = min(abs(awayreward(z)-currentcluster));
          [cc indexmax] = min(abs(awayreward(z+1)-currentcluster));
          newcluster = currentcluster(indexmin:indexmax);
          if length(newlfp)>500 & length(newcluster)>6 %good with 6
          [awayrewardkappa(end+1) meanphaseaway(end+1) devaway(end+1)] = spikethetaphase(newcluster, newlfp, newtime, 0);
          allaway(end+1) = awayrewardkappa(end);
          else
            awayrewardkappa(end+1) = NaN;
            meanphaseaway(end+1) = NaN;
            devaway = NaN;
            allaway(end+1) = NaN;
          end
          z = z+2;
      end

      awayrewardkappa = nanmean(awayrewardkappa);
      meanphaseaway = nanmean(meanphaseaway);


      dif = torewardkappa-awayrewardkappa;
      newdata = {name; length(currentcluster); torewardkappa; awayrewardkappa; meanphasetowards; meanphaseaway};
      output = horzcat(output, newdata);
  end

  f = output';
    save('kappa_mid_prefphase2.mat','f')
  notes = [numpoint; allcaps];
