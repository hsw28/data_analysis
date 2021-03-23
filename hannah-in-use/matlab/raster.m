function f = raster(spiketrain_of_times, starttime, endtime)

spiketrain = spiketrain_of_times;
% Create a figure with axes
ax = gca;


% Figure out axes resolution
oldunits = get(ax,'Units');
set(ax,'Units','Pixels');
pos = get(ax,'Position')
xpixels = floor(pos(3));               % Number of pixels on x axes
%xpixels = (endtime-starttime)*70;
ypixels = floor(pos(4));               % Number of pixels on y axes
set(ax,'Units',oldunits)
% need to input number of clusters/tetrodes/MUA channels to be drawn as
% independent rows. spiketrain is a cell array with spike times for each
% spike train to be plotted
nrasters = size(spiketrain,2);
% need to input time window to be plotted
twin = [starttime endtime];%
% What is your x resolution?
xresolution = diff(twin)/xpixels
% How many pixels will you use on in the y direction per tick mark?
pixperrast = floor(ypixels/(nrasters+2));
% This is what gets plotted
RGBgrid = ones(ypixels,xpixels,3);

% Which x pixels need to be drawn?
xvector = twin(1):xresolution:twin(2);


% This row vector will be used to populate RGBgrid
indgrid = RGBgrid(1,:,:);

nrasters
for ii = 1:nrasters
    % how many spikes in each spike train fall within each pixel that can
    % be drawn? spiketrain is a cell array with spike times for each spike
    % train to be plotted
    currspike = spiketrain(:,ii);
    count = histc(currspike,xvector);
    xpix = count(1:end-1) > 0;


    yrange = pixperrast*(ii) : floor(pixperrast*(ii+0.9));

    rgb = indgrid;

    rgb(1,xpix,1) = 0;  % red channel
    rgb(1,xpix,2) = 0;  % green channel
    rgb(1,xpix,3) = 0;  % blue channel

    % Now enter into larger matrix
    RGBgrid(yrange,:,:) = repmat(rgb,[length(yrange),1,1]);
end

% Draw the image on axes

image('Xdata',xvector,'YData',0:nrasters+1,'CData',RGBgrid,'Parent',ax);
% Adjust image to occupy entire axes area
set(ax,'xlim',twin,'ylim',[0 nrasters+1])
