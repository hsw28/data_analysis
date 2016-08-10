function plot_pre_spike(indiv_traces,ts,varargin)

p = inputParser();
p.addParamValue('timewin',[-0.005 -0.001]);
p.addParamValue('polar',false);
p.addParamValue('plot_chans',[1 2 3]);
p.addParamValue('color',[0 0 1]);
p.addParamValue('plot_fn',[]);
p.parse(varargin{:});
opt = p.Results;

n_plots = size(opt.timewin,1);

for m = 1:n_plots
keep_log = and(ts >= opt.timewin(m,1), ts <= opt.timewin(m,2));
n_trace = size(indiv_traces,3);

dat1 = cell(1,n_trace);
dat2 = cell(1,n_trace);
dat3 = cell(1,n_trace);
for n = 1:n_trace
    dat1{n} = indiv_traces(keep_log, opt.plot_chans(1), n);
    dat2{n} = indiv_traces(keep_log, opt.plot_chans(2), n);
    dat3{n} = indiv_traces(keep_log, opt.plot_chans(3), n);
end
if(~isempty(opt.plot_fn))
    for n = 1:n_trace
        dat1{n} = opt.plot_fn(dat1{n});
        dat2{n} = opt.plot_fn(dat2{n});
        dat3{n} = opt.plot_fn(dat3{n});
    end
end

dat1 = cell2mat(dat1);
dat2 = cell2mat(dat2);
dat3 = cell2mat(dat3);

plot3(dat1',dat2',dat3','.','MarkerSize',10,'Color',opt.color(m,:));
hold on;
end