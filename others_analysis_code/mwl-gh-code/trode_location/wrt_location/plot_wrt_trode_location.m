function f = plot_wrt_trode_location(data, trode_fun, rat_conv_table, varargin)

default_i_vals = unique([data.lfp.chanlabels, cellfun(@(x) x.comp, data.mua.clust,'UniformOutput',false)]);
default_j_vals = default_i_vals;

p = inputParser();
p.addParamValue('trode_i',default_i_vals);
p.addParamValue('trode_j',{'01'});
p.addParamValue('timewin',[]);
p.addParamValue('sub_xlim',[-0.1 0.1]);
p.addParamValue('sub_ylim',[-1 1]);
p.addParamValue('sub_x_size', [-.1 .1]);
p.addParamValue('sub_y_size', [-.25 .25]);
p.addParamValue('trode_groups',[]);
p.addParamValue('trig_time',[]);
p.parse(varargin{:});
opt = p.Results;

opt.rat_conv_table = rat_conv_table;

scalex = diff(opt.sub_x_size)/diff(opt.sub_xlim);
scaley = diff(opt.sub_y_size)/diff(opt.sub_ylim);
Sxy = makehgtform('scale',[scalex,scaley,1]);

ax = axes('XLim',[-20,20],'YLim',[-20,20]);

if(isempty(opt.trode_groups))
    error('plot_wrt_trode_location:no_trode_groups','Pass trode_groups please');
end
opt.c_eeg = trode_colors(data.lfp, opt.trode_groups);
opt.c_mua = trode_colors(data.mua, opt.trode_groups);

for i = 1:numel(opt.trode_i)
    h = trode_fun(data, opt.trode_i{i}, opt.trode_j, opt);
    t = hgtransform('Parent',ax);
    set(h,'Parent',t);
    ap = trode_conv(opt.trode_i{i}, 'comp','brain_ap',rat_conv_table);
    ml = trode_conv(opt.trode_i{i}, 'comp','brain_ml',rat_conv_table);
    TAnatomy = makehgtform('translate',[ml,ap,0]);
    TInput   = makehgtform('translate', [-opt.trig_time,0,0]);
    set(t,'Matrix', TAnatomy * Sxy * TInput);
end

%axis equal;
xlim([0,4]);
ylim([-6, -1]);

if(~isempty(opt.trig_time))
title(num2str(opt.trig_time));
end

% f = figure('KeyPressFcn',@lfun_fig_keypress);
% 
% gd.f = f;
% gd.data = data;
% gd.opt = opt;
% gd.opt.rat_conv_table = rat_conv_table;
% gd.trode_fun = trode_fun;
% gd.trode_i = opt.default_trode_i;
% gd.trode_j = opt.default_trode_j;
% 
% guidata(f, gd);
% lfun_draw_plot(gd);
% axis equal;
% 
% end
% 
% 
% function lfun_draw_plot(gd)
% 
% clf(gd.f)
% gd.trode_fun(gd.data, gd.trode_i, gd.trode_j, gd.opt);
% set(gd.f,'NextPlot','replace');
% 
% end
% 
% function lfun_fig_keypress(src, eventdata)
% gd = guidata(src);
% if(strcmp(eventdata.Key,'rightarrow'))
%     gd.trode_i = gd.trode_i + 1;
% elseif(strcmp(eventdata.Key,'leftarrow'))
%     gd.trode_i = gd.trode_i - 1;
% end
% guidata(src,gd);
% lfun_draw_plot(gd);
% end