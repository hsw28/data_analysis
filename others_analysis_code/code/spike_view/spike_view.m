function sv_f = spike_view(sdat,cdat,pos,varargin)

p = inputParser;
p.addParamValue('v_timewin',[],@isreal);
p.parse(varargin{:});
opt = p.Results;

sv.f = figure('Visible','on','Position',[360 500 800 750]);
%sv.axis_c = axes('Parent',sv.f,'units','normalized','Position',[0.05,0.5,0.4,0.45]);
sv.axis_a = axes('Parent',sv.f,'units','normalized','Position',[0.05,0.05,0.9,0.9]);

hold(sv.axis_a,'on');

sv.sdat = sdat;
sv.cdat = cdat;
sv.pos = pos;

guidata(sv.f,sv);

sv_f = sv.f;