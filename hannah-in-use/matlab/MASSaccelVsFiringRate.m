function f = MASSaccelVsFiringRate(spikestructure, posstructure, timestructure, windowsize)
  %use clusterimport.m and posimport.m and timeimport.m to create spike and position structures
  %does conversion factor if needed for early recordings
  %window size is in seconds

%determine how many spikes
spikenames = (fieldnames(spikestructure));
spikenum = length(spikenames);

output = {'cluster name'; '# spikes'; '# points on graph'; 'slope'; 'r2 value'; 'p value'};

for k = 1:spikenum
    name = char(spikenames(k));
    % get date of spike
    date = strsplit(name,'cluster_'); %splitting at year
    date = char(date(1,2));
    date = regexp(date,'(?=[maze])_1_|_2_|_3_|_4_|_5_|_6_|_7_|_8_|_9_|_10_|_11_|_12_|_13_|_14_|_15_|_16_|_17_|_18_|_19_|_20_|_21_|_22_|_23_|_24_|_25_|_26_|_27_|_28_|_29_|_30_|_31_|_32_','split');
    date = char(date(1,1));
    % formats date to be same as in position structure: date_2015_08_01_acc
    accformateddate = strcat(date, '_acc');
    accformateddate = strcat('date_', accformateddate);
    % formats date to be same as in time structure: date_2015_08_01_time
    timeformateddate = strcat(date, '_time');
    timeformateddate = strcat('date_', timeformateddate);
    % formats date to be same as in time structure: date_2015_08_01_position
    posformateddate = strcat(date, '_position');
    posformateddate = strcat('date_', posformateddate);

    %get conversion factor
    numdate = {date};
    numdate = char(strrep(numdate,'_',''));
    numdate = str2num(numdate);
      if numdate < 20170427
        actualseconds = length(timestructure.(timeformateddate)) / 2000;
        fakeseconds = timestructure.(timeformateddate)(end)-timestructure.(timeformateddate)(1);
        conversion = actualseconds/fakeseconds;
      else
        conversion = 1;
      end


    % limit the times in the time file to those in position files
    starttime = posstructure.(posformateddate)(1,1);
    endtime = posstructure.(posformateddate)(end,1);
    starttime = find(abs(timestructure.(timeformateddate)-starttime) < .001);
    endtime = find(abs(timestructure.(timeformateddate)-endtime) < .001);
    starttime = starttime(1,1);
    endtime = endtime(1,1);
    time = [timestructure.(timeformateddate)(starttime:endtime)];


    % does the thing
    % want to decide on output-- maybe number of spikes, slope, and r2 value
    spikename = char(spikenames(k));
    set(0,'DefaultFigureVisible', 'off');
    accvrate = accelVsFiringRate((time.*conversion), (posstructure.(accformateddate).*conversion), (spikestructure.(spikename).*conversion), windowsize);
    x = accvrate(:,1);
    actualvals = find(~isnan(x));
    x = x(actualvals);
    y = accvrate(:,2);
    y = y(actualvals);
    coeffs = polyfit(x, y, 1);
    slope = coeffs(1); % get slope of best fit line
    intercept = coeffs(2);
    % Get fitted values
    polydata = polyval(coeffs,x);
    sstot = sum((y - mean(y)).^2);
    ssres = sum((y - polydata).^2);
    rsquared = 1 - (ssres / sstot); % get r^2 value


    spikesizes = spikestructure.(spikename);
    stats = fitlm(x,y);
    pval = stats.Coefficients.pValue(2);

    % made chart with name, number of spikes, number of points on graph, slope, and r2 value, and p value from t test
    newdata = {name; length(spikesizes); size(x,1); slope; rsquared; pval};

    output = horzcat(output, newdata);
  end

% outputs chart with spike name, number of spikes, slope, and r2 value
  f = output;