function f = cm_init_gui(f,sdat,userdata)

cm_h = guidata(f);
cm_h.sdat = sdat;

cm_h.new_sdat = sdat;
cm_h.new_sdat.clust = cell(0);

nclust = numel(sdat.clust);
for i = 1:nclust
    % add a tracking number
    sdat.clust{i}.tracking_number = i;
end

% import epoch info
[cm_h.enames,cm_h.ebounds] = get_epoch_info();
cm_h.nepoch = numel(cm_h.enames);
enames = cm_h.enames;
ebounds = cm_h.ebounds;
nepoch = cm_h.nepoch;
% get window info
wpos = get(f,'Position');
win_width = wpos(3);
win_height = wpos(4);

cm_h.sdat = sdat;

border = 0.02;
bottom_panel_height = 0; % save 300 px for isi hists, buttons, etc
nborder = nepoch+1;
paxis_wid = (1-(nepoch+1)*border)/nepoch;
paxis_top = 1-border;
paxis_height = 0.3;

saxis_width = (1-(nepoch*4+1)*border)/(nepoch*4);
saxis_height = 0.25;
saxis_bottom = 0.40;

haxis_width = (1-(nepoch+1)*border)/(nepoch);
haxis_height = 0.20;
haxis_bottom = 0.15;

cm_h.paxis = zeros(1,nepoch); % paxis will an array of handles to projection axes
cm_h.saxis = zeros(nepoch,4); % saxis shows waveforms
cm_h.haxis = zeros(1,nepoch); % axes for histograms of, for example, isi
cm_h.clust_popup = zeros(1,nepoch); % buttons for picking from among clusters
cm_h.clust_pop_labels = zeros(1,nepoch); % labels for 

for i = 1:nepoch
    this_pos = [i * border + (i-1)*paxis_wid, paxis_top-paxis_height, paxis_wid,paxis_height];
    cm_h.paxis(i) = axes('Parent',f,'units','normalized','Position',this_pos);
    hold on;
    for j = 1:4
        this_pos = [((i-1)*4+(j-1))*saxis_width + ((4*(i-1)+j)*border),saxis_bottom,saxis_width,saxis_height];
        cm_h.saxis(i,j) = axes('Parent',f,'units','normalized','Position',this_pos);
        hold on
    end
    this_pos = [i * border + (i-1)*haxis_width,haxis_bottom,haxis_width,haxis_height];
    cm_h.haxis(i) = axes('Parent',f,'units','normalized','Position',this_pos);
    this_pos = [(i-1)/nepoch+border,0.07,0.1,0.03];
    cm_h.clust_pop_labels(i) = uicontrol('Parent',f,...
        'Units','normalized','Position',this_pos,'Style','text',...
        'String',[enames{i},':'],'Callback',{'cm_update_views',f,1});
    this_pos = this_pos + [0.1 0 0.2 0];
    cm_h.clust_popup(i) = uicontrol('Parent',f,'Style',...
    'popupmenu','Units','normalized','Position',this_pos,...
    'String',{'1'},'Callback',{'cm_update_views'});
end
%linkprop(cm_h.paxis,{'View'});

cm_h.label_1 = uicontrol('Parent',f,'Style','text','String','X:','Position',[10 30 20 15]);
cm_h.label_2 = uicontrol('Parent',f,'Style','text','String','Y:','Position',[150 30 20 15]);
cm_h.label_3 = uicontrol('Parent',f,'Style','text','String','Z:','Position',[300 30 20 15]);
cm_h.x_param_popup = uicontrol('Parent',f,'Style','popupmenu',...
'String',['none', sdat.clust{1}.featurenames],...
'Value',1,'units','pixels','Position',[45 30 100 15],...
'Callback',{'cm_update_views'});
cm_h.y_param_popup = uicontrol('Parent',f,'Style','popupmenu',...
    'String',['none', sdat.clust{1}.featurenames],...
    'Value',1,'units','pixels','Position',[180 30 100 15],...
    'Callback',{'cm_update_views'});
cm_h.z_param_popup = uicontrol('Parent',f,'Style','popupmenu',...
    'String',['none', sdat.clust{1}.featurenames],...
    'Value',1,'units','pixels','Position',[320 30 100 15],...
    'Callback',{'cm_update_views'});

cm_h.label_t = uicontrol('Parent',f,'Style','text','String','Trode:','Position',[450 30 50 15]);
cm_h.trode_popup = uicontrol('Parent',f,'Style','popupmenu',...
    'String',{'0'},'Position',[500 30 50 15],...
    'Callback',{'cm_select_trode'});


cm_h.plot_all = uicontrol('Parent',f,'Style','checkbox','String','Plot All Clusts',...
    'Value',1,'Position',[560 30 50 20],'Min',0,'Max',1,'Callback',{'cm_update_views'});

cm_h.label_anal = uicontrol('Parent',f,'Style','text','String','Anal:','Position',[620 30 50 15]);
cm_h.anal_popup = uicontrol('Parent',f,'Style','popupmenu','String',{'isi','acorr'},...
    'Position',[680 30 50 15],'Callback',{'cm_update_anal'});

cm_h.waveforms_button = uicontrol('Parent',f,'Style','pushbutton','String','Plot waveforms',...
    'Position',[10 5 150 20],'Callback',{'cm_plot_waveforms'});

cm_h.match_button = uicontrol('Parent',f,'Style','pushbutton','String','Match',...
    'Position',[560 5 50 20],'Callback',{'cm_match'});
cm_h.done_button = uicontrol('Parent',f,'Style','pushbutton','String','Done',...
    'Position',[610 5 50 20],'Callback',{'cm_done'});
cm_h.toggle_interneuron_button = uicontrol('Parent',f,'Style','pushbutton','String','Toggle Interneuron',...
    'Position',[200 5 150 20],'Callback',{'cm_toggle_interneuron'});
cm_h.toggle_noisecluster_button = uicontrol('Parent',f,'Style','pushbutton','String','Toggle Noise Cluster',...
    'Position',[350 5 150 20],'Callback',{'cm_toggle_noisecluster'});

trode_names = cell(0);
% collect all trode names
for i = 1:nclust
    trode_names = [trode_names,sdat.clust{i}.trode];
end
trode_names = unique(trode_names);

set(cm_h.trode_popup,'String',trode_names);

cm_h.current_from_tt_file = [];

for i = 1:nepoch
    cm_h.wave_id(i) = 0;
end

%guihandles(f)
guidata(f,cm_h);
%g = guidata(f)

set(cm_h.x_param_popup,'Value',3);
set(cm_h.y_param_popup,'Value',4);
set(cm_h.z_param_popup,'Value',5);

cm_select_trode(f,userdata);