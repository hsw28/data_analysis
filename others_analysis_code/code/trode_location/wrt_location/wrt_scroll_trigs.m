function f = wrt_scroll_trigs(lfp,mua,trigs,varargin)

p = inputParser();

f = figure('KeyPressFcn',@lfun_fig_keypress);

gd.f = f;
gd.data.lfp = lfp;
gd.data.mua = mua;
gd.opt = opt;
gd.opt.rat_conv_table = rat_conv_table;
gd.trode_fun = trode_fun;
gd.trode_i = opt.default_trode_i;
gd.trode_j = opt.default_trode_j;

guidata(f, gd);
lfun_draw_plot(gd);
axis equal;

end


function lfun_draw_plot(gd)