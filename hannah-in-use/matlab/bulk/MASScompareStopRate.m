function output = MASScompareStopRate(spikestructure, posstructure)

  spikename = (fieldnames(spikestructure));
  spikenum = length(spikename);
  previousdate = 0;

output = {'name'; 'size'; 'rew_rate'; 'nonrewrate'};

  for k = 1:spikenum
    rewspike = [];
    nonrewspike = [];
      name = char(spikename(k))
      currentspike = spikestructure.(name);
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
      accformateddate = strcat(date, '_acc');
      accformateddate = strcat('date_', accformateddate);
      % formats date to be same as in time structure: date_2015_08_01_time
      timeformateddate = strcat(date, '_time');
      timeformateddate = strcat('date_', timeformateddate);
      % formats date to be same as in time structure: date_2015_08_01_position
      posformateddate = strcat(date, '_position');
      posformateddate = strcat('date_', posformateddate);
      % vel
      velformateddate = strcat(date, '_vel');
      velformateddate = strcat('date_', velformateddate);

      %%%%%%%ONLY DO IF NEW DATE
      newdate = {date};
      newdate = char(strrep(newdate,'_',''));
      newdate = strsplit(newdate,'rat');
      newdate = char(newdate(1,2));
    newdate = str2num(newdate);

      if newdate ~= previousdate
        previousdate = newdate;
        fprintf('new date')
        slowtimes = veltimes(posstructure.(velformateddate), 5, 1); %finds stopping times
        slowlocation = placeevent(slowtimes(:,1), fixpos(posstructure.(posformateddate)));

        Xrew = find(slowlocation(2,:) > 750); %find X at reward
        Yrew = find(slowlocation(3,:) < 182 | slowlocation(:,3) > 575);

        rewtimeindx = intersect(Xrew, Yrew);
        rewtime = slowtimes(rewtimeindx, :);
        rewtimelength = sum(rewtime(:,3));

        nonrewtimeindx = [1:length(slowtimes)];
        nonrewtimeindx = setdiff(nonrewtimeindx, rewtimeindx);
        nonrewtime = slowtimes(nonrewtimeindx, :);
        nonrewtimelength = sum(nonrewtime(:,3));
      end


      for n=1:length(rewtime)
        rs = (length(find(currentspike>=rewtime(n,1) & currentspike<=rewtime(n,2))));
        rewspike(end+1) = rs ./ (rewtime(n,2)-rewtime(n,1));
      end


      for n=1:length(nonrewtime)
        nrs = (length(find(currentspike>=nonrewtime(n,1) & currentspike<=nonrewtime(n,2))));
        nonrewspike(end+1) = nrs ./ (nonrewtime(n,2)-nonrewtime(n,1));

      end

      rewrate = mean(rewspike);
      nonrewrate = mean(nonrewspike);

      newdata = {name; length(currentspike); rewrate; nonrewrate};
      output = horzcat(output, newdata);

end

output = output';
