function [trig,thresh] = gh_find_trig(sdat,varargin)

p=inputParser();
p.addParamValue('trig_chan',1);
p.addParamValue('thresh_type','sig',@(x) any(strcmp(x,{'sig','diff'})));
p.addParamValue('thresh',[]);
p.addParamValue('pre_examine',false);
p.addParamValue('post_examine',true);
p.addParamValue('examine_timewin',1);
p.addParamValue('refractory_period',0.006);
p.addParamValue('min_block_interval',1);
p.addParamValue('exper',[]);
p.parse(varargin{:});
opt = p.Results;

ts = conttimestamp(sdat);
data = sdat.data(:,opt.trig_chan)';
if(strcmp(opt.thresh_type,'diff'))
    data = [0 diff(data)];
end

% flip everything if thresh is negative, so that >= means 'more extreme in
% same direction'
%subplot(2,1,1); plot(ts,data); hold on; plot(ts,opt.thresh.*ones(size(ts)));

data = data * sign(opt.thresh);
opt.thresh = opt.thresh * sign(opt.thresh);
%subplot(2,1,1); plot(ts,data); hold on; plot(ts,opt.thresh.*ones(size(ts)));

if(opt.pre_examine)
    plot(ts,data);
    xlim(t_max_y+ opt.examine_timewin*[-1/2 1/2]);
    [x,opt.thresh] = getpts();
    if(length(opt.thresh) > 1)
        warning('dropping all but first point');
    end
    opt.thresh = opt.thresh(1);
end

trig_bool = logical([0 diff(data >= opt.thresh)]);
trig_times = ts(trig_bool);
trig_ind = find(trig_bool);
refrac_ok_bool = logical([1,diff(trig_times) >= opt.refractory_period]);
trig_times = trig_times(refrac_ok_bool);
trig_ind = trig_ind(refrac_ok_bool); % this is spaghetti code
first_in_block = [1 diff(trig_times) > opt.min_block_interval];

all_trigs = trig_times;
block_trigs = trig_times(logical(first_in_block));
thresh = opt.thresh; % in case ppl want to recover this from their click

trig.time = all_trigs;
trig.first_in_block = first_in_block;
trig.ind = trig_ind;
if(~isempty(opt.exper))
    trig.state = cell(size(trig_times));
    for n = 1:length(opt.exper.times)
        this_bool = trig.time >= opt.exper.times(n);
        trig.state(this_bool) = opt.exper.state(n);
    end
end

n_trig = length(trig_times);
n_block = length(block_trigs);
if(opt.post_examine)
    plot(ts,data);
    hold on;
    dat_range = max(data)-min(data);
    yparts = [min(data),min(data)-dat_range/10, min(data)-dat_range/5];
    xs = NaN .* zeros(1,3*n_trig); ys = xs;
    xs([0:n_trig-1]*3+1) = trig_times;
    ys([0:n_trig-1]*3+1) = yparts(1);
    xs([0:n_trig-1]*3+2) = trig_times;
    ys([0:n_trig-1]*3+2) = yparts(2);
    plot(xs,ys,'g-');
    xs = NaN .* zeros(1,3*n_block); ys = xs;
    xs([0:n_block-1]*3+1) = block_trigs;
    ys([0:n_block-1]*3+1) = yparts(2);
    xs([0:n_block-1]*3+2) = block_trigs;
    ys([0:n_block-1]*3+2) = yparts(3);
    plot(xs,ys,'b-');
end