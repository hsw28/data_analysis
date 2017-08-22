function f = MASSCHUNKcorrFiringRate(spikestructure, posstructure, time, bins)
  %use clusterimport.m and MASSchunkingruns.m to create spike and position structures
  % time can be a normal time file
  %bin in ms
  %does conversion factor if needed for early recordings
  %window size is in seconds
  %
  %right now can ONLY do from one day,so make sure all clusters are from the SAME DAY as the pos, time, etc

%determine how many different position files
posnames = (fieldnames(posstructure));
posnum = length(posnames)./3;

output = {'cluster name'; '# spikes'; 'vel corr'; 'acc corr';'type'; 'spike name'};


k=1;
while k <= posnum

    name = char(posnames(k))
    date = strsplit(name,'_position');
    date = char(date(1,1)); % now have for ex date_2017_04_28_trial_1_forced

    velformateddate = strcat(date, '_vel');
    accformateddate = strcat(date, '_acc');
    posformateddate = strcat(date, '_position');

    type = regexp(date, 'forced|middle|reward', 'split');
    type = type(1,2);


    %timeformateddate = regexp(date, '_forced|_middle|_reward', 'split');
    %timeformateddate = char(timeformateddate(1,1));
    %timeformateddate = strcat(date, '_time')

    %clusterformat = regexp(date, '_forced|_middle|_reward', 'split');
    %clusterformat = char(clusterformat(1,1));
    %clusterformat = strsplit(date, 'date_');
    %clusterformat = (1,2);
    %clusterformat = strcat(date, 'cluster_');
    % not actually the cluster format since it doesnt have cl_clustnum after it. but not sure i need this section anyway

    %get conversion factor
    numdate = strsplit(name,'date_');
    numdate = numdate(1,2);
    %now have for ex 2017_04_28_trial_1_forced
    numdate = strsplit(name,'_trial');
    numdate = numdate(1,1); %now have for ex 2017_04_28
    %numdate = {numdate};
    numdate = strrep(numdate,'_','');
    numdate = str2num(char(numdate));
      if numdate < 20170427
        actualseconds = length(timestructure.(timeformateddate)) / 2000;
        fakeseconds = timestructure.(timeformateddate)(end)-timestructure.(timeformateddate)(1);
        conversion = actualseconds/fakeseconds;
      else
        conversion = 1;
      end

    % limit the times in the time file to those in position files
    starttime = posstructure.(posformateddate);
    if length(starttime) < 1
        break
    end
    posstarttime = posstructure.(posformateddate)(1,1);
    posendtime = posstructure.(posformateddate)(end,1);
    starttime = find(abs(time-posstarttime) < .001);
    endtime = find(abs(time-posendtime) < .001);
    starttime = starttime(1,1);
    endtime = endtime(1,1);
    newtime = [time(starttime:endtime)];


    %permute through all clusters and do the thing
    q = 1;
    spikenames = fieldnames(spikestructure);
    spikenums = length(spikenames);
    while q <= (spikenums)
        % does the thing
        spike = char(spikenames(q));
        set(0,'DefaultFigureVisible', 'off');
        
        confinedspikes = find(spikestructure.(spike)>=posstarttime & spikestructure.(spike)<=posendtime);
        confinedspikes = (spikestructure.(spike)(confinedspikes));
        spikehis = spikehisto(confinedspikes.*conversion, newtime.*conversion, bins);

        vel = assignvel(newtime.*conversion, posstructure.(velformateddate).*conversion);
        acc = assignvel(newtime.*conversion, posstructure.(accformateddate).*conversion);



        w = warning('query','last');
        id = w.identifier;
        warning('off',id);

        numbins = length(spikehis);
        round(length(vel)./numbins);
        velbins = binning(vel', (length(vel)./numbins));
        accbins = binning(acc', (length(acc)./numbins));

        velcorr = (corr(velbins', spikehis'));
        acccorr = (corr(accbins', spikehis'));
        size(velcorr);
        velcorr = velcorr(1,:);
        acccorr = acccorr(1,:);
        velcorr = max(abs(velcorr));
        acccorr = max(abs(acccorr));


        % made chart with name, number of spikes, number of points on graph, slope, and r2 value, and p value from t test

        newdata = {name; length(spikenames(q)); velcorr; acccorr; char(type); spikenames(q)};
        %i think spike number is wrong bc its total number of spikes not number in the time bin
        output = horzcat(output, newdata);
        q = q+1;



    end

    %positions are 3 in a row (forced middle reward), seperated by 6 (vel and acc)
    if k==1 | k==2 | rem(k, 9) == 1 | rem(k, 9) == 2
        k = k+1;
    else
        k = k+7;
    end

  end

% outputs chart with spike name, number of spikes, slope, and r2 value
  f = output';

  set(0,'DefaultFigureVisible', 'on');
