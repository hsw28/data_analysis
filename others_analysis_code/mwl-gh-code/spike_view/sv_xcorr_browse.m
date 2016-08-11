function f = sv_xcorr_browse(xcorr,varargin)

p = inputParser();
p.addParamValue('m',1,@isreal);
p.addParamValue('n',2,@isreal);
p.parse(varargin{:});

data.m = p.Results.m;
data.n = p.Results.n;
data.sdat = sdat;

data.f = figure('Position',[50 50 400 300],'KeyPressFcn',@localfn_figure_keypress);

localfn_plot_xcorr(xcorr,m,n);

%data.axes = bar(sdat.clust{1}.field.bin_centers,sdat.clust{1}.field.out_rate,'b');
%hold on
%bar(sdat.clust{1}.field.bin_centers,-1.*sdat.clust{1}.field.in_rate,'r');
%data.i = 1;
%title([sdat.clust{1}.name,'  index: ' num2str(data.i)]);
data.xcorr = xcorr;
guidata(data.f,data);
f = data.f;

function localfn_figure_keypress(src,eventdata)
data = guidata(src);

if strcmp(eventdata.Key,'rightarrow')
    data.m = data.m + 1;
elseif strcmp(eventdata.Key, 'leftarrow')
    data.m = data.m - 1;
elseif strcmp(eventdata.Key, 'uparrow')
    data.n = data.n - 1;
elseif strcmp(eventdata.Key, 'downarrow')
    data.n = data.n + 1;
end

localfn_plot_phase(data.xcorr,data.m,data.n);
guidata(data.f,data);

function localfn_plot_phase(xcorr,m,n)

plot(xcorr.steps,xcorr.xcorr_values(m,n,:));
xlim([min(xcorr.steps),max(xcorr.steps)]);
ylim([0 1]);


text(0.1,.09,['m: ', num2str(data.m), '  n: ', num2str(n)]);