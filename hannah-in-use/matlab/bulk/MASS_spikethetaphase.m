function [LSpeak kappavec] = MASS_spikethetaphase(LSspikestructure, HPCspikestructure, lfpstructure, timestructure)

  figure
  hpcspikenames = fieldnames(HPCspikestructure);
  hpcspikenum = length(hpcspikenames);

  spikenames = (fieldnames(LSspikestructure));
  spikenum = length(spikenames);
  output = {'cluster name'; '# spikes'; 'kappa'; 'rayleigh' };
  previousdate = 0;
  LSpeak = [];
  kappavec = [];

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
        % formats lfp to be same as in lfp structure: date_2015_08_01_position
        lfpformateddate = strcat(date, '_lfp');
        lfpformateddate = strcat('date_', lfpformateddate);

        newdatechar = date;
        newdate = {date};
        newdate = char(strrep(newdate,'_',''));
        newdate = strsplit(newdate,'rat');
        newdate = char(newdate(1,2));
        newdate = str2num(newdate);



      if newdate ~= previousdate & isfield(timestructure, (timeformateddate))==1 & isfield(lfpstructure, (lfpformateddate))==1
        disp('new date!')
        previousdate =  newdate;
        time = [timestructure.(timeformateddate)];
          lfp = [lfpstructure.(lfpformateddate)];
          lfp = thetafilt412(lfp);
          f = lfp;
          hilly = hilbert(lfp);

          %getting HPC
          goodmax = [];
          for z = 1:hpcspikenum
            hpcname = char(hpcspikenames(z));
            if contains(hpcname,newdatechar) == 1
              currentclusterhpc = HPCspikestructure.(hpcname);
              hpctheta_phase = interp1(time(1:length(hilly)), unwrap(angle(hilly)), currentclusterhpc);
              rad = limit2pi(hpctheta_phase(~isnan(hpctheta_phase)));
              kappa = circ_kappa(rad);
              if kappa>.1
                histcounts(rad2deg(rad), [0:10:360]);
                [M,I] = max(histcounts(rad2deg(rad), [0:10:360]));
                goodmax(end+1) = (I*10)-5;
              end
            end
          end
            maxrad = meanangle(goodmax); %this is max spiking
            maxrad = deg2rad(maxrad);
            %let us define that as phase 0-- so you subtract that phase from all others

          spikename = char(spikenames(k))
          currentcluster = LSspikestructure.(spikename);
          theta_phase = interp1(time(1:length(hilly)), unwrap(angle(hilly)), currentcluster);
          %f = theta_phase;
          size(maxrad)
          theta_phase = theta_phase-maxrad(1); %subtracting for HPC
          rad = limit2pi(theta_phase(~isnan(theta_phase)));
          if length(rad)>1
            kappa = circ_kappa(rad);
            rayleigh = circ_rtest(rad);
            newdata = {spikename; length(LSspikestructure.(spikename)); kappa; rayleigh};
            output = horzcat(output, newdata);
            %figure
            %histogram(rad2deg(rad), 'BinWidth', 20, 'Normalization', 'probability')
          end
      elseif newdate == previousdate
        disp('same date! will not refilter')
        spikename = char(spikenames(k))
        currentcluster = LSspikestructure.(spikename);
        theta_phase = interp1(time(1:length(hilly)), unwrap(angle(hilly)), currentcluster);
        theta_phase = theta_phase-maxrad; %subtracting for HPC
        rad = limit2pi(theta_phase(~isnan(theta_phase)));
        if length(rad)>1
        kappa = circ_kappa(rad);
        rayleigh = circ_rtest(rad);
        newdata = {spikename; length(LSspikestructure.(spikename)); kappa; rayleigh};
        output = horzcat(output, newdata);
        %figure
        %histogram(rad2deg(rad), 'BinWidth', 20, 'Normalization', 'probability')
        end
      end



%if kappa>=.3
      kappavec(end+1) = kappa;
    %  plot(histcounts(rad2deg(rad), [0:10:360], 'Normalization', 'probability'));
    %  hold on
      [M,I] = max(histcounts(rad2deg(rad), [0:10:360]));
      LSpeak(end+1) = (I*10)-5;
%end


end
 LSpeak;
 kappavec;
%f = output';
