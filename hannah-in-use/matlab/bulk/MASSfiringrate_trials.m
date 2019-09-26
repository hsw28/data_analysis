function f = MASSfiringrate_trials(structureofspikes, posstructure, timestructure)
  %unfilted LFP
  %finds kappa for choice direction on middle stem by trial, so you can compare correct and incorrect trials




spikenames = fieldnames(structureofspikes);
spikenum = length(spikenames);

posnames = fieldnames(posstructure);
posnum = length(posnames);

%plots = ceil(spikenum./3);
%output = {'cluster name'; 'length'; 'mean kappa to reward'; 'mean kappa away from reward'; 'mean phase to'; 'mean phase away'; 'std to'; 'std away'};

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

      newdatechar = char(posformateddate);
      % formats lfp to be same as in lfp structure: date_2015_08_01_position
      lfpformateddate = strcat(date, '_lfp');
      lfpformateddate = strcat('date_', lfpformateddate);

      newdatechar = strcat(date, '_lfp');
      newdate = {date};
      newdate = char(strrep(newdate,'_',''));
      newdate = strsplit(newdate,'rat');

      newdatechar2 = char(newdate(1,2));
      newdate = str2num(newdatechar2);
    %  newdatechar = char(strcat('date_', char(newdate)));

      currentpos = posstructure.(posformateddate);
      currenttime = timestructure.(timeformateddate);
      currentcluster = structureofspikes.(name);


      if newdate ~= previousdate

        previousdate = newdate;
        if k>1
        %MyStruct.(previousdatechar) = [nanmean(MyStruct.(previousdatechar)); toreward([1:2:end])];
        MyStruct.(previousdatechar) = MyStruct.(previousdatechar)(1:dayspikecount-1, :);
        fprintf('new date')
        end
        [toreward, awayreward] = middletimes(currentpos, 1);
        rt = rewardtimes(currentpos, 1);

        dayspikecount = 1;
        %MyStruct.newdate = newdatechar;
        MyStruct.(newdatechar) = NaN(50, length(toreward)./2);
      end

      previousdatechar = newdatechar;



      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      meanphasetowards = [];
      devtowards = [];

      %%%
      newclusterlength = 0;
      while z<=length(toreward)
          [cc entryindex] = (min(abs(rt(:,1)-toreward(z))));
          if (rt(entryindex,1))-toreward(z)<0
            entryindex = entryindex+1;
          end

          [cc indexmin] = min(abs((rt(entryindex,1)-2)-currentcluster));
          [cc indexmax] = min(abs(rt(entryindex,1)-currentcluster));
          newclusterlength = length(currentcluster(indexmin:indexmax));

          %MyStruct.(newdatechar)(dayspikecount, (z+1)/2, k) = torewardkappa;
          MyStruct.(newdatechar)(dayspikecount, (z+1)/2) = newclusterlength;


          z = z+2;
      end

      dayspikecount = dayspikecount+1;

    %  newdata = {name; length(currentcluster); torewardkappa; awayrewardkappa; meanphasetowards; meanphaseaway; devtowards; devaway};
    %  output = horzcat(output, newdata);
  end

MyStruct.(newdatechar) = MyStruct.(newdatechar)(1:dayspikecount-1, :);

%MyStruct.(newdatechar) = [nanmean(MyStruct.(newdatechar)); toreward([1:2:end])];

f = MyStruct;

%  f = output';
%    save('kappa_mid_prefphase.mat','f')
%  notes = [numpoint; allcaps];
