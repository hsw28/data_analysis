function f = MASSripplerate(spikestructure, posstructure, timestructure, lfpstructure, usevel, startorpeak)
  %IF USE VEL = 0 VELOCITY IS NOT USED TO FIND RIPPLES. IF =1 IT IS. RIGHT NOW YOU STILL PUT IN POS EITHER WAY
  %IF YOU SELECT ZERO THEN TIME ISNT CUT TO POSITION FILE TIMES. IF YOU SELECT 1 IT IS
  % FOR START OR PEAK-- ENTER 0 FOR START, 1 FOR PEAK
  %
  %DONT IMPORT FILTERED lfps
  %
  %use clusterimport.m and posimport.m and timeimport.m to create spike and position structures
  %does conversion factor if needed for early recordings
  %
  % Finds difference in spike rast before, during, after ripples.
  %take 20ms around each side of peak for ripple rate
  %for pre ripple take 100-60ms before
  %for post ripple take 60-100ms after


%determine how many spikes
spikenames = (fieldnames(spikestructure));
spikenum = length(spikenames);

output = {'cluster name'; '# spikes'; 'spikes pre rip'; 'spikes rip'; 'spikes post rip'; 'rip/pre-rip'; 'rip/post-rip'; 'post-rip/pre-rip' };

figure
previousdate = 0;
for k = 1:spikenum

    name = char(spikenames(k))
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

      % formats lfp to be same as in time structure: date_2015_08_01_position
      lfpformateddate = strcat(date, '_lfp');
      lfpformateddate = strcat('date_', lfpformateddate);

      newdate = {date};
      newdate = char(strrep(newdate,'_',''));
      newdate = strsplit(newdate,'rat');
      newdate = char(newdate(1,2));
      newdate = str2num(newdate);

    if newdate ~= previousdate
      disp('new date!')
      previousdate =  newdate;
      %get conversion factor
        %if numdate < 20170427
        %  actualseconds = length(timestructure.(timeformateddate)) / 2000;
        %  fakeseconds = timestructure.(timeformateddate)(end)-timestructure.(timeformateddate)(1);
        %  conversion = actualseconds/fakeseconds;
        %else
          conversion = 1;
      %  end


        % limit the times in the time file to those in position files

        if usevel == 1
          starttime = posstructure.(posformateddate)(1,1);
          endtime = posstructure.(posformateddate)(end,1);
          starttime = find(abs(timestructure.(timeformateddate)-starttime) < .001);
          endtime = find(abs(timestructure.(timeformateddate)-endtime) < .001);
          starttime = starttime(1,1);
          endtime = endtime(1,1);
          time = [timestructure.(timeformateddate)(starttime:endtime)];
          lfp = [lfpstructure.(lfpformateddate)(starttime:endtime)];
          rips = findrip(lfp, (time.*conversion), 2.5, posstructure.(velformateddate).*conversion);
        elseif usevel == 0
          time = timestructure.(timeformateddate);
          lfp = lfpstructure.(lfpformateddate);
          rips = findrip(lfp, (time.*conversion), 2.5, 0);
        end
    else
      disp('same date! will not refilter')
    end

    spikename = char(spikenames(k));

    if startorpeak == 1
      allchanges = psth(.2, 41, rips(2,:), (spikestructure.(spikename).*conversion));
    elseif startorpeak == 0
        allchanges = psth(.5, 101, rips(1,:), (spikestructure.(spikename).*conversion));
    end

%{
    size(allchanges)
    %take 20ms around each side for ripple rate
    totalrip = allchanges(18)+allchanges(22);
    %for pre ripple take 100-60ms before
    totalprerip = allchanges(8)+allchanges(12);
    %for post ripple take 60-100ms after
    totalpostrip = allchanges(28)+allchanges(32);


    newdata = {name; length(spikestructure.(spikename)); totalprerip; totalrip; totalpostrip; totalrip/totalprerip; totalrip/totalpostrip;  totalpostrip/totalprerip};

    %output = {'cluster name'; '# spikes'; 'spikes pre rip'; 'spikes rip'; 'spikes post rip'; 'rip/pre-rip'; 'rip/post-rip'; 'postrip/prerip' };

          output = horzcat(output, newdata);
%}
          hold on
          plot(allchanges/allchanges(1))
end

% outputs chart with spike name, number of spikes, slope, and r2 value
  f = output';
