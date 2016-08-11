function f = cm_init_gui(f,sdat,userdata)

% import epoch info
fname = dir('*.epoch');
filea = textread(fname(1).name,'%s','delimiter','\n','whitespace','','commentstyle','matlab');
nepoch = numel(file);
ebounds = zeros(2,nepoch);
ename = cell(1,nepoch);
for i = 1:nepoch
    [ename{i},this_start,this_end] = strread(file{i},'%s,%f,%f','delimiter','	');
    ebounds(:,i) = [this_start,this_end];
end

% get window info
wpos = get(f,'Position');
win_width = wpos(3);
win_height = wpos(4);

% collect all epochs & count them
nclust = numel(sdat.clust);
epoch_names = cell(0);
for i = 1:nclust
    epoch_names = [epoch_names,sdat.clust{i}.epochs];
end
epoch_names = unique(epoch_names);
nepoch = numel(epoch_names);

border_px = 10;
bottom_panel_px = 300; % save 300 px for isi hists, buttons, etc
nborder = nepoch+1;
axis_wid = (win_width - border_px*(nepoch+1))/nepoch;
axis_top = win_height - border_px;
axis_height = win_height - bottom_panel_px;

eaxis = zeros(1,nepoch); % eaxis will an array of handles to projection axes

for i = 1:nepoch
    eaxis(i) = axes('Parent','f','Position',[i*border_px + (i-1)*axis_wid, axis_top,axis_wid,axis_height);
end