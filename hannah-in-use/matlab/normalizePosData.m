function [rate totspikes totstime] = normalizePosData(eventData,posData,dim)
%TO DO: add figure saving

%This function bins event data based on a user input bin size and
%normalizes based on total time spent in bin
%color maps with range based on highest and lowest three percent of firing
%Args:
%   eventData: A timeseries of cell firings (e.g. the output of abovetheta)
%   posData: The matrix of overall position data with columns [time,x,y]
%   dim: Bin size in cm (only square bins are supported)
%
%
%   ex: map = normalizePosData(lsevents, pos, 4)
%
%Output:
%   rate: A discritized matrix of cell events per second
%   heatmap: A heatmap of the rate matrix



if size(eventData, 1)>size(eventData,2)
	eventData = eventData';
end

eventData = cutclosest(posData(1,1), posData(end,1), eventData, eventData);
ls = placeevent(eventData,posData);

ls = ls';
psize = 3.5 * dim; %some REAL ratio of pixels to cm


%only find occupancy map if one hasn't been provided

	xmax = max(posData(:,2));
	xmin = min(posData(:,2));
	ymax = max(posData(:,3));
	ymin = min(posData(:,3));
	xbins = ceil((xmax)/psize);
	ybins = ceil((ymax)/psize);

	time = zeros(ybins,xbins);
	events = zeros(ybins,xbins);
	xstep = xmax/xbins;
	ystep = ymax/ybins;
	%tstep = (posData(end,1)-posData(1,1))./length(posData);
	tstep = 1/30;


	for i = 1:xbins
    	for j = 1:ybins
        	A1 = posData(:,2)>((i-1)*xstep) & posData(:,2)<=(i*xstep); %finds all rows that are in the current x axis bin
        	A2 = posData(:,3)>((j-1)*ystep) & posData(:,3)<=(j*ystep); %finds all rows that are in the current y axis bin
        	A = [A1 A2]; %merge results
        	B = sum(A,2); %find the rows that satisfy both previous conditions
        	C = B > 1;
        	time(ybins+1-j,i) = sum(C); %set the matrix cell for that bin to the number of rows that satisfy both
    	end
		end



for i = 1:xbins
    for j = 1:ybins
        A1 = ls(:,2)>((i-1)*xstep) & ls(:,2)<=(i*xstep); %finds all rows that are in the current x axis bin
        A2 = ls(:,3)>((j-1)*ystep) & ls(:,3)<=(j*ystep); %finds all rows that are in the current y axis bin
        A = [A1 A2]; %merge results
        B = sum(A,2); %find the rows that satisfy both previous conditions
        C = B > 1;
        events(ybins+1-j,i) = sum(C); %set the matrix cell for that bin to the number of rows that satisfy both
    end
end


rate = events./(time*tstep); %time*tstep is occupancy

totspikes = events;
totstime = (time*tstep);
%rate = rate(:, 15:end-20);



%heat map stuff
%figure

%{
[nr,nc] = size(rate);
colormap('parula');
%lower and higher three percent of firing sets bounds
numrate = rate(~isnan(rate));
numrate = sort(numrate(:),'descend');
maxratefive = min(numrate(1:ceil(length(numrate)*0.03)));
numrate = sort(numrate(:),'ascend');
minratefive = max(numrate(1:ceil(length(numrate)*0.03)));

pcolor([rate nan(nr,1); nan(1,nc+1)]);
shading flat;
set(gca, 'ydir', 'reverse');
if minratefive ~= maxratefive
		set(gca, 'clim', [minratefive*1.5, maxratefive*.75]);
end
colorbar;
%}
