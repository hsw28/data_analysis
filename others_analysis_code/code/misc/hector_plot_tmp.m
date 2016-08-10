%% General stuff

n_timebins = 9;
n_spacebins = 9;

ts = (-1*(n_timebins-1)/2):((n_timebins-1)/2);
pos =  (-1*(n_spacebins-1)/2):((n_spacebins-1)/2);

ts_lim = [min(ts), max(ts)];
pos_lim = [min(pos), max(pos)];

x_tick = linspace(min(ts_lim) - (ts(2)/2 - ts(1)/2),...
    max(ts_lim) + (ts(2)/2 - ts(1)/2), n_timebins + 1);

y_tick = linspace(min(pos_lim) - (pos(2)/2 - pos(1)/2),...
    max(pos_lim) + (pos(2)/2 - pos(1)/2), n_spacebins + 1);

asym_frac = 0.99;
A = max(pos_lim);

n_x = 500;
n_y = n_x;
x = linspace(min(x_tick), max(x_tick), n_x);
% y = 1./(1+exp(-1 * r .* x);  %in general

%% Plot1: different asymtote vals

asym_time = 3;
r = -1*log( 1/ (asym_frac) - 1) / asym_time;

scale_levels = 1/n_timebins

y = 1./(1 + exp(-1 * r .* x));

%[xx,yy] = meshgrid(


set(gca,'XTick',x_tick);
set(gca,'YTick',y_tick);
xlim([min(x_tick), max(x_tick)]);