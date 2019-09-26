function f = MASSpowermap(spikestructure, posstructure, dim, vel_or_acc)

  %really used for velocity or acc mapping. put 1 for vel and 2 for acc
  %the spike structure is just used to get the days you want

  spikename = (fieldnames(spikestructure));
  spikenum = length(spikename);



set(0,'DefaultFigureVisible', 'off');
previousdate = 0;
xcoord = [];
ycoord = [];
oldpos = 0;
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

      velformateddate = strcat(date, '_vel');
      velformateddate = strcat('date_', velformateddate);

      accformateddate = strcat(date, '_acc');
      accformateddate = strcat('date_', accformateddate);

      newdatechar = date;
      newdatechar = date;
      newdate = {date};
      newdate = char(strrep(newdate,'_',''));
      newdate = strsplit(newdate,'rat');
      newdate = char(newdate(1,2));
      newdate = str2num(newdate);

      if vel_or_acc == 1
        powerdata = posstructure.(velformateddate);
      elseif vel_or_acc == 2
        powerdata = abs(posstructure.(accformateddate));
      end

      currentposstring = posformateddate;
      currentpos = posstructure.(posformateddate);


    if newdate ~= previousdate
        previousdate = newdate;
        %currentpos = [currentpos; [maxtime+.03, 0, 0]; [maxtime+.06, 1500, 1500]];
        chart = powermap(powerdata, currentpos, dim, 0, 50);
        [maxValue, linearIndexesOfMaxes] = max(chart(:));
        %chart = chart./nanmean(chart, 'all');
        chart = chart./maxValue;
        if k == 1
          endchart = zeros(size(chart));
        end
        chart(isnan(chart))=0;
        size(chart)
        size(endchart)
        endchart = endchart + chart;
    end
    oldpos = currentposstring;
end

endchart(endchart==0) = NaN;
endchart = endchart(size(endchart,2)-70:end, 1:100);

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
