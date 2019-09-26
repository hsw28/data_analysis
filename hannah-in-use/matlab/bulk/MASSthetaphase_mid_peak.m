function [f notes] = MASSthetaphase_mid_peak(structureofspikes, hpcspikesstructure, posstructure, timestructure, lfpstructure)
  %unfilted LFP
  %finds theta phase for choice versus free in middle arm (directional)




    hpcspikenames = fieldnames(hpcspikesstructure);
    hpcspikenum = length(hpcspikenames);

spikenames = fieldnames(structureofspikes);
spikenum = length(spikenames);

%plots = ceil(spikenum./3);
output = {'cluster name'; 'length'; 'mean phase to'; 'mean phase away'};

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

%%%%%%%%%%%%%
      %find HPC amount to subtract for each date
      if newdate ~= previousdate & isfield(timestructure, (timeformateddate))==1 & isfield(lfpstructure, (lfpformateddate))==1
        disp('new date!')
        previousdate =  newdate;          %getting HPC
        time = [timestructure.(timeformateddate)];
          lfp = [lfpstructure.(lfpformateddate)];
          lfp = thetafilt412(lfp);
          lfp = hilbert(lfp);

          goodmax = [];
          for z = 1:hpcspikenum
            hpcname = char(hpcspikenames(z));
          if contains(hpcname,newdatechar) == 1
            currentclusterhpc = hpcspikesstructure.(hpcname);
            hpctheta_phase = interp1(time(1:length(lfp)), unwrap(angle(lfp)), currentclusterhpc);
            rad = limit2pi(hpctheta_phase(~isnan(hpctheta_phase)));
            if length(rad)>1
            kappa = circ_kappa(rad);
            %if kappa>.1
              histcounts(rad2deg(rad), [0:5:360]);
              [M,I] = max(histcounts(rad2deg(rad), [0:5:360]));
              goodmax(end+1) = (I*5)-2.5;
            else
              goodmax = NaN;
            end
          end
        end
          goodmax = goodmax(~isnan(goodmax));
          maxrad = meanangle(goodmax); %this is max spiking
          maxrad = deg2rad(maxrad);

          [toreward, awayreward] = middletimes(currentpos, 1);
    end
%%%%%%%%%%%%%
      currentlfp = lfp;
      currenttime = timestructure.(timeformateddate);
      currentcluster = structureofspikes.(name);

      if length(currentlfp)~=length(currenttime)
        warning('your time must be same as your lfp')
      end



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
          newlfp = [newlfp; currentlfp(indexmin:indexmax)];
          newtime = [newtime, currenttime(indexmin:indexmax)];

          [cc indexmin] = min(abs(toreward(z)-currentcluster));
          [cc indexmax] = min(abs(toreward(z+1)-currentcluster));
          if length(currentcluster)>=1
          newcluster = [newcluster; currentcluster(indexmin:indexmax)];
          end

          z = z+2;
      end

      if length(newlfp)>2000 & length(newcluster)>12
      current_LS.(name) = newcluster;
      current_LFP.(lfpformateddate) = newlfp;
      current_TIME.(timeformateddate) = newtime;
      meanphasetowards(end+1) = MASS_spikethetaphase(current_LS, hpcspikesstructure, current_TIME, current_LFP, 1, maxrad);
      %[torewardkappa(end+1) meanphasetowards(end+1) devtowards(end+1)] = spikethetaphase(newcluster, newlfp, newtime, 0);
      current_LS = rmfield(current_LS, (name));
      current_LFP = rmfield(current_LFP, (lfpformateddate));
      current_TIME = rmfield(current_TIME, (timeformateddate));
      else
        torewardkappa(end+1) = NaN;
        meanphasetowards(end+1) = NaN;
        devtowards(end+1) = NaN;
      end
      numpoint(end+1) = length(newcluster);

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
          newlfp = [newlfp; currentlfp(indexmin:indexmax)];
          newtime = [newtime, currenttime(indexmin:indexmax)];

          [cc indexmin] = min(abs(awayreward(z)-currentcluster));
          [cc indexmax] = min(abs(awayreward(z+1)-currentcluster));
          if length(currentcluster)>=1
          newcluster = [newcluster; currentcluster(indexmin:indexmax)];
          end

          z = z+2;
      end

      if length(newlfp)>2000 & length(newcluster)>12
        current_LS.(name) = newcluster;
        current_LFP.(lfpformateddate) = newlfp;
        current_TIME.(timeformateddate) = newtime;
        meanphaseaway(end+1) = MASS_spikethetaphase(current_LS, hpcspikesstructure, current_TIME, current_LFP, 1, maxrad);
      %[awayrewardkappa(end+1) meanphaseaway(end+1) devaway(end+1)] = spikethetaphase(newcluster, newlfp, newtime, 0);
      current_LS = rmfield(current_LS, (name));
      current_LFP = rmfield(current_LFP, (lfpformateddate));
      current_TIME = rmfield(current_TIME, (timeformateddate));
      else
      awayrewardkappa(end+1) = NaN;
      meanphaseaway(end+1) = NaN;
      devaway(end+1) = NaN;
      end
      numpoint(end+1) = length(newcluster);

      %av_to_reward = mean(torewardkappa(~isnan(torewardkappa)));
      %av_away_reward = mean(awayrewardkappa(~isnan(awayrewardkappa)));

      dif = torewardkappa-awayrewardkappa;
      newdata = {name; length(currentcluster); meanphasetowards; meanphaseaway};
      output = horzcat(output, newdata);
  end

  f = output';
    save('kappa_mid_prefphase.mat','f')
  notes = [numpoint; allcaps];
