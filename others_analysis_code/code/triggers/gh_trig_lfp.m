function [rel_ts,mean_dat,n_trig,indiv_dat] = gh_trig_lfp(cdat,trig,varargin)

p=inputParser();
p.addParamValue('timerange',[-0.5 0.5]);
p.addParamValue('include_time',[cdat.tstart,cdat.tend]);
p.addParamValue('must_be_block_start',true);
p.addParamValue('state',[]);
p.addParamValue('chan_ind',1:size(cdat.data,2));
p.parse(varargin{:});
opt = p.Results;

opt.include_time = [max([opt.include_time(1),cdat.tstart]),...
    min([opt.include_time(2),cdat.tend])];

% bool for trig times are all at least timerange away from the lfp bounds
keep_trig = and(trig.time >= opt.include_time(1) - opt.timerange(1),...
    trig.time <= opt.include_time(2) - opt.timerange(2));

% bool for trig times are first trig in block (block was defined in
% gh_find_trig
if(opt.must_be_block_start)
    keep_trig = and(keep_trig,...
        trig.first_in_block);
end

% bool for state selection
if(~isempty(opt.state))
    keep_trig = and(keep_trig,...
        strcmp(opt.state,trig.state));
end

trig.time = trig.time(keep_trig);
trig.first_in_block = trig.first_in_block(keep_trig);
trig.ind = trig.ind(keep_trig);
trig.state = trig.state(keep_trig);

dt = (cdat.tend - cdat.tstart)/(size(cdat.data,1)-1);
timewin_samps = round(opt.timerange / dt);
used_timewin = timewin_samps * dt;
rel_ts = used_timewin(1):dt:used_timewin(2);
n_rel_ts = length(rel_ts);

n_trig = sum(keep_trig);
%trig.ind = 
trig_ind = trig.ind;
rel_ind = timewin_samps(1):timewin_samps(2);
n_rel_ind = length(rel_ind);
ind_array = repmat(rel_ind,n_trig,1) + repmat(trig_ind',1,n_rel_ind);

n_chans = length(opt.chan_ind);
data_array = zeros(n_trig,n_rel_ind,n_chans);
for n = 1:n_chans
    this_data = cdat.data(:,n)';
    data_array(:,:,n) = this_data(ind_array);
end
indiv_dat = data_array;
mean_dat.data = mean(indiv_dat,1);
mean_dat.data = reshape(mean_dat.data,n_rel_ind,n_chans)';
mean_dat.stdev = std(indiv_dat,1);
mean_dat.stderr = mean_dat.stdev ./ sqrt(n_trig-1);
mean_dat.stdev = reshape(mean_dat.stdev,n_rel_ind,n_chans)';
mean_dat.stderr = reshape(mean_dat.stderr,n_rel_ind,n_chans)';

