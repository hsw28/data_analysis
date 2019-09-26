function f  = MASSthetaphase_mid3(structureofspikes, posstructure, timestructure, lfpstructure)
  %unfilted LFP
  %finds theta phase for choice versus free in middle arm




spikenames = fieldnames(structureofspikes);
spikenum = length(spikenames);

%plots = ceil(spikenum./3);
output = {'cluster name'; 'length'; 'mean kappa to reward1'; 'mean kappa away from reward1'; 'to2' ; 'away2'; 'to3'; 'away3'};

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

      %if newdate ~= previousdate & isfield(timestructure, (timeformateddate))==1 & isfield(posstructure, (posformateddate))==1 & isfield(lfpstructure, (lfpformateddate))==1

      currentpos = posstructure.(posformateddate);
      currentlfp = lfpstructure.(lfpformateddate);
      currenttime = timestructure.(timeformateddate);
      currentcluster = structureofspikes.(name);

      if length(currentlfp)~=length(currenttime)
        warning('your time must be same as your lfp')
      end

      [toreward1, awayreward1, toreward2, awayreward2, toreward3, awayreward3] = middletimes3(currentpos);


      torewardkappa1temp = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      while z<=length(toreward1)
          [cc indexmin] = min(abs(toreward1(z)-currenttime));
          [cc indexmax] = min(abs(toreward1(z+1)-currenttime));
          newlfp = [currentlfp(indexmin:indexmax)];
          newtime = [currenttime(indexmin:indexmax)];

          [cc indexmin] = min(abs(toreward1(z)-currentcluster));
          [cc indexmax] = min(abs(toreward1(z+1)-currentcluster));
          newcluster = [currentcluster(indexmin:indexmax)];

          if length(newcluster)>6 && length(newlfp)>300
          torewardkappa1temp(end+1) = spikethetaphase(newcluster, newlfp, newtime, 0);
          else
          torewardkappa1temp(end+1) = NaN;
          end

          z = z+2;
      end
      torewardkappa1 = nanmean(torewardkappa1temp);


      %now away from reward
      awayrewardkappa1temp = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      while z<=length(awayreward1)
          [cc indexmin] = min(abs(awayreward1(z)-currenttime));
          [cc indexmax] = min(abs(awayreward1(z+1)-currenttime));
          newlfp = [currentlfp(indexmin:indexmax)];
          newtime = [currenttime(indexmin:indexmax)];

          [cc indexmin] = min(abs(awayreward1(z)-currentcluster));
          [cc indexmax] = min(abs(awayreward1(z+1)-currentcluster));
          newcluster = currentcluster(indexmin:indexmax);

          if length(newcluster)>6 && length(newlfp)>300
          awayrewardkappa1temp(end+1) = spikethetaphase(newcluster, newlfp, newtime, 0);
          else
          awayrewardkappa1temp(end+1) = NaN;
          end

          z = z+2;
      end

      awayrewardkappa1 = nanmean(awayrewardkappa1temp);


      %%%%%%%%%%%%%%%%%

      torewardkappa2temp = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      while z<=length(toreward2)
          [cc indexmin] = min(abs(toreward2(z)-currenttime));
          [cc indexmax] = min(abs(toreward2(z+1)-currenttime));
          newlfp = [currentlfp(indexmin:indexmax)];
          newtime = [currenttime(indexmin:indexmax)];

          [cc indexmin] = min(abs(toreward2(z)-currentcluster));
          [cc indexmax] = min(abs(toreward2(z+1)-currentcluster));
          newcluster = [currentcluster(indexmin:indexmax)];

          if length(newcluster)>6 && length(newlfp)>300
          torewardkappa2temp(end+1) = spikethetaphase(newcluster, newlfp, newtime, 0);
          else
          torewardkappa2temp(end+1) = NaN;
          end

          z = z+2;
      end

      torewardkappa2 = nanmean(torewardkappa2temp);


      %now away from reward
      awayrewardkappa2temp = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      while z<=length(awayreward2)
          [cc indexmin] = min(abs(awayreward2(z)-currenttime));
          [cc indexmax] = min(abs(awayreward2(z+1)-currenttime));
          newlfp = [currentlfp(indexmin:indexmax)];
          newtime = [currenttime(indexmin:indexmax)];

          [cc indexmin] = min(abs(awayreward2(z)-currentcluster));
          [cc indexmax] = min(abs(awayreward2(z+1)-currentcluster));
          newcluster = [currentcluster(indexmin:indexmax)];

          if length(newcluster)>6 && length(newlfp)>300
          awayrewardkappa2temp(end+1) = spikethetaphase(newcluster, newlfp, newtime, 0);
          else
          awayrewardkappa2temp(end+1) = NaN;
          end
          z = z+2;
      end

      awayrewardkappa2 = nanmean(awayrewardkappa2temp);



      %%%%%%%%%%%%%%%%%

      torewardkappa3temp = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      while z<=length(toreward3)
          [cc indexmin] = min(abs(toreward3(z)-currenttime));
          [cc indexmax] = min(abs(toreward3(z+1)-currenttime));
          newlfp = [currentlfp(indexmin:indexmax)];
          newtime = [currenttime(indexmin:indexmax)];

          [cc indexmin] = min(abs(toreward3(z)-currentcluster));
          [cc indexmax] = min(abs(toreward3(z+1)-currentcluster));
          newcluster = [currentcluster(indexmin:indexmax)];

          if length(newcluster)>6 && length(newlfp)>300
          torewardkappa3temp(end+1) = spikethetaphase(newcluster, newlfp, (newtime), 0);
          else
            torewardkappa3temp(end+1) = NaN;
          end

          z = z+2;
      end

      torewardkappa3 = nanmean(torewardkappa3temp);


      %now away from reward
      awayrewardkappa3temp = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      while z<=length(awayreward3)
          [cc indexmin] = min(abs(awayreward3(z)-currenttime));
          [cc indexmax] = min(abs(awayreward3(z+1)-currenttime));
          newlfp = [currentlfp(indexmin:indexmax)];
          newtime = [currenttime(indexmin:indexmax)];

          [cc indexmin] = min(abs(awayreward3(z)-currentcluster));
          [cc indexmax] = min(abs(awayreward3(z+1)-currentcluster));
          newcluster = [currentcluster(indexmin:indexmax)];

          if length(newcluster)>6 && length(newlfp)>300
          awayrewardkappa3temp(end+1) = spikethetaphase(newcluster, newlfp, newtime, 0);
          else
          awayrewardkappa3temp(end+1) = NaN;
          end

          z = z+2;
      end

      awayrewardkappa3 = nanmean(awayrewardkappa3temp);


      %%%%%%%%%%

      newdata = {name; length(currentcluster); torewardkappa1; awayrewardkappa1; torewardkappa2; awayrewardkappa2; torewardkappa3; awayrewardkappa3};
      output = horzcat(output, newdata);
  end

  f = output';

  save('kappa3.mat','f')
