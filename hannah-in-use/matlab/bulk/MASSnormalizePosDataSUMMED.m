function f = MASSnormalizePosDataSUMMED(spikestructure, posstructure, dim)

%sums accross all inputted data

%This function bins event data based on a user input bin size and
%normalizes based on total time spent in bin
%color maps with range based on highest and lowest three percent of firing
%Args:
%   eventData: A timeseries of cell firings (e.g. the output of abovetheta)
%   posData: The matrix of overall position data with columns [time,x,y]
%   dim: Bin size in cm (only square bins are supported)

spikename = (fieldnames(spikestructure));
spikenum = length(spikename);



set(0,'DefaultFigureVisible', 'off');

xcoord = [];
ycoord = [];
for k = 1:spikenum
    name = char(spikename(k))
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

    currentpos = posstructure.(posformateddate);
    maxtime = max(currentpos(:,1));

    currentpos = [currentpos; [maxtime+.03, 0, 0]; [maxtime+.06, 1500, 1500]];

    chart = normalizePosData(spikestructure.(name), currentpos, dim);

    sigma = 1; % set sigma to the value you need
    %sz = 2*ceil(2.6 * sigma) + 1; % See note below
    sz = 3;
    mask = fspecial('gauss', sz, sigma);
    %chart = nanconv(chart, mask, 'same');
    [maxValue, linearIndexesOfMaxes] = max(chart(:));
    %[colsOfMaxes rowsOfMaxes] = find(smoothchart == maxValue);

    chart = chart./nanmean(chart, 'all');
    %chart = chart./maxValue;
    if k == 1
      endchart = zeros(size(chart));
    end
    chart(isnan(chart))=0;
    endchart = endchart + chart;

    %[colsOfMaxes rowsOfMaxes] = find(chart == maxValue);



    %if length(rowsOfMaxes) >1
    %  v = randi(length(rowsOfMaxes));
    %  rowsOfMaxes = rowsOfMaxes(v);
    %  colsOfMaxes = colsOfMaxes(v);
    %end


    %psize = 3.5 * dim;
    %xmax = max(posstructure.(posformateddate)(:,2));
    %xbins = ceil(xmax/psize);
    %xstep = xmax/xbins;
    %xcoord(end+1) = rowsOfMaxes * xstep;

    %ymax = max(posstructure.(posformateddate)(:,3));
    %ybins = ceil(ymax/psize);
    %ystep = ymax/ybins;
    %ycoord(end+1) = colsOfMaxes * ystep;


end

endchart(endchart==0) = NaN;
endchart = endchart(size(endchart,2)-70:end, 1:100);

%plot endchart
set(0,'DefaultFigureVisible', 'on');
figure
[nr,nc] = size(endchart);
colormap('parula');
%lower and higher three percent of firing sets bounds
numendchart = endchart(~isnan(endchart));
numendchart = sort(numendchart(:),'descend');
maxendchartfive = min(numendchart(1:ceil(length(numendchart)*0.03)));
numendchart = sort(numendchart(:),'ascend');
minendchartfive = max(numendchart(1:ceil(length(numendchart)*0.03)));

pcolor([endchart nan(nr,1); nan(1,nc+1)]);
shading flat;
set(gca, 'ydir', 'reverse');
%set(gca,'clim',[0,lim]);
if minendchartfive ~= maxendchartfive
		set(gca, 'clim', [minendchartfive*1.2, maxendchartfive*1]);
end
axis([16 (size(endchart, 2)+5) -4 (size(endchart,1))]);
colorbar;
