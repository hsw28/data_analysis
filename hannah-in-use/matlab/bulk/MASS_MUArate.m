function [f notes] = MASS_MUArate(structureofspikes, posstructure)

%combines all spiking for a day and gets spike rate
set(0,'DefaultFigureVisible', 'off');
output = {'day'; 'overallrate'; 'rate1'; 'rate2'; 'rate3'};

spikenames = fieldnames(structureofspikes);
spikenum = length(spikenames);

previousdate = 0;
maxcc = [];
for k=1:spikenum
    name = char(spikenames(k));
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

      if newdate ~= previousdate
        if k>1 | k==spikenum
          rate = normalizePosData(spikeall, oldpos , 4);

          overallrate = nanmean(reshape(rate, [size(rate,1)*size(rate,2), 1]));
          rate1 = nanmean(reshape(rate(19:23, 31:41), [55, 1]));
          rate2 = nanmean(reshape(rate(19:23, 41:52), [60, 1]));
          rate3 = nanmean(reshape(rate(19:23, 52:62), [55, 1]));

          newdata = {olddate; overallrate; rate1; rate2; rate3};
          output = horzcat(output, newdata);
        end

        spikeall = [];
        disp('new date!')
        previousdate =  newdate;
        goodmax = [];
        for z = 1:spikenum
          name = char(spikenames(z));
          if contains(name,newdatechar) == 1
            currentcluster = structureofspikes.(name);
            spikeall = vertcat(spikeall, currentcluster);
            end
        end
      elseif k==spikenum
        rate = normalizePosData(spikeall, oldpos , 4);

        overallrate = nanmean(reshape(rate, [size(rate,1)*size(rate,2), 1]));
        rate1 = nanmean(reshape(rate(19:23, 31:41), [55, 1]));
        rate2 = nanmean(reshape(rate(19:23, 41:52), [60, 1]));
        rate3 = nanmean(reshape(rate(19:23, 52:62), [55, 1]));

        newdata = {olddate; overallrate; rate1; rate2; rate3};
        output = horzcat(output, newdata);

      end
        spikeall = sort(spikeall);

        olddate = newdatechar;
        oldpos = [posstructure.(posformateddate)];

end

f = output';
