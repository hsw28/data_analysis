function [f] = sv_field_browse(sdat, varargin)

p = inputParser();
p.addParamValue('pos_info',[]);
p.parse(varargin{:});

data.use_pos = ~isempty(p.Results.pos_info);
if(data.use_pos)
    data.pos_info = p.Results.pos_info;
end
data.keep_list = [];

data.f = figure('Position',[50 50 400 300],'KeyPressFcn',@localfn_figure_keypress);


%data.axes = bar(sdat.clust{1}.field.bin_centers,sdat.clust{1}.field.out_rate,'b');
%hold on
%bar(sdat.clust{1}.field.bin_centers,-1.*sdat.clust{1}.field.in_rate,'r');
data.i = 1;
%title([sdat.clust{1}.name,'  index: ' num2str(data.i)]);
data.sdat = sdat;
guidata(data.f,data);

localfn_draw(data);

f = data.f;
keep_list = data.keep_list;

function localfn_figure_keypress(src,eventdata)
data = guidata(src);

disp(eventdata.Key);
if strcmp(eventdata.Key,'rightarrow')
    data.i = data.i + 1;
    data.this_name = data.sdat.clust{data.i}.comp
elseif strcmp(eventdata.Key, 'leftarrow')
    data.i = data.i - 1;
    data.this_name = data.sdat.clust{data.i}.comp
elseif strcmp(eventdata.Key, 'uparrow');
    data.keep_list = [data.keep_list,data.i]
    disp(['Added to keep_list cell at index: ',num2str(data.i)]);
elseif strcmp(eventdata.Key, 'return');
    assignin('caller','keep_list',data.keep_list);
    disp(['Assigned variable keep_list into the calling function (or workspace)']);
end

guidata(data.f,data);
localfn_draw(data);

function localfn_draw(data)
sdat = data.sdat;
figure(data.f);
clust = sdat.clust{data.i};

if(data.use_pos)    
    
    x_col = strcmp(clust.featurenames,'pos_x');
    y_col = strcmp(clust.featurenames,'pos_y');
    t_col = strcmp(clust.featurenames,'time');
    pos_out_col = strcmp(clust.featurenames,'out_pos_at_spike');
    pos_in_col = strcmp(clust.featurenames,'in_pos_at_spike');
    out_rows = ~isnan(clust.data(:,pos_out_col));
    in_rows = ~isnan(clust.data(:,pos_in_col));
    x_out = clust.data(out_rows,x_col);
    y_out = clust.data(out_rows,y_col);
    t_out = clust.data(out_rows,t_col);
    x_in = clust.data(in_rows,x_col);
    y_in = clust.data(in_rows,y_col);
    t_in = clust.data(in_rows,t_col);
    
    h(1) = subplot(2,2,2);
    bar(clust.field.bin_centers,clust.field.out_rate,'b','Parent',h(1));
    hold on;
    bar(clust.field.bin_centers,-1*clust.field.in_rate,'r','Parent',h(1));
    ylim([-40,40]);
    hold off;

    h(2) = subplot(2,2,1);
    data.pos_info.x_filt.data( isnan(data.pos_info.x_filt.data) ) = 0;
    data.pos_info.y_filt.data( isnan(data.pos_info.y_filt.data) ) = 0;
    plot(data.pos_info.x_filt.data',data.pos_info.y_filt.data','k.','MarkerSize',1,'Parent',h(2)); 
    hold on;
    plot(x_out,y_out,'b.','Parent',h(2));
    plot(x_in,y_in,'r.','Parent',h(2)); hold off;
    axis equal;
    
    hb(1) = subplot(2,2,3);
    plot(conttimestamp(data.pos_info.x_filt),data.pos_info.x_filt.data','k.','MarkerSize',1); hold on;
    plot(conttimestamp(data.pos_info.y_filt),data.pos_info.y_filt.data','k.','MarkerSize',1);
  %  plot(clust.data(out_rows,t_col),clust.data(out_rows,x_col),'b.','Parent',hb(1));
  %  plot(clust.data(out_rows,t_col),clust.data(out_rows,y_col),'b.','Parent',hb(1));
   % plot(clust.data(in_rows,t_col),clust.data(in_rows,x_col),'r.','Parent',hb(1));
  %  plot(clust.data(in_rows,t_col),clust.data(in_rows,y_col),'r.','Parent',hb(1)); hold off;
    
    hb(2) = subplot(2,2,4);
    plot(conttimestamp(data.pos_info.lin_filt),data.pos_info.lin_filt.data,'k.','MarkerSize',1,'Parent',hb(2)); hold on;
    lin_col = strcmp(clust.featurenames,'pos_at_all_spikes');
    plot(clust.data(out_rows,t_col),clust.data(out_rows,lin_col),'b.','Parent',hb(2));
    plot(clust.data(in_rows,t_col),clust.data(in_rows,lin_col),'r.','Parent',hb(2)); hold off;
    linkaxes(hb,'x');
    title(num2str(data.i));
end
    