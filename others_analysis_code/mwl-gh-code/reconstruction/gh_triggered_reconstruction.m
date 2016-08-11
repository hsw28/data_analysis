function [r_pos_out,trigs] = gh_triggered_reconstruction(r_pos_in,pos,varargin)

p = inputParser();
p.addParamValue('time_range',[-0.2 0.2],@(x) all(size(x) == [1 2])); % pre-post trig window
p.addParamValue('r_pos_n_shift',[]);
p.addParamValue('pos_range',[-0.5 0.5]); % pre-post position range to display
p.addParamValue('anal_range',[]); % global time range for analysis
p.addParamValue('lfp',[]);
p.addParamValue('phase_cdat',[]);
p.addParamValue('trig_times',[]);
p.addParamValue('env_cdat',[]);
p.addParamValue('extra_time_buffer',0,@isreal); % extra padding on allowable time windows
p.addParamValue('min_theta_power',[],@isreal); 
p.addParamValue('ok_pos_range',r_pos_in(1).x_range); % rat pos's to prosess
p.addParamValue('min_vel',0.2,@isreal);
p.addParamValue('normalize_within_chan',false,@islogical);
p.addParamValue('lfp_chan',[]);
p.addParamValue('phase',0);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;


% set up time bouts for accepting triggers
total_time = diff(opt.time_range);
crit_range = opt.time_range + [-1 1]*opt.extra_time_buffer;

if(~isempty(opt.r_pos_n_shift))
    nRow = size(r_pos_in(1),1);
    assert(numel(r_pos_n_shift == numel(r_pos_in)));
    for c = 1:numel(r_pos_n_shift)
        this_shift = r_pos_n_shift(c);
        if (this_shift > 0)
            r_pos_in(c).pdf_by_t = ...
                [zeros(nRow,this_shift), r_pos_in(c).pdf_by_t(:,1:(end - thisShift))];
        elseif (this_shift < 0)
            r_pos_in(c).pdf_by_t = ...
                [r_pos_in(c).pdf_by_t(:,thisShift:end), zeros(nRow,this_shift)];
        else
            r_pos_in(c).pdf_by_t = r_pos_in(c).pdf_by_t;
        end    
    end

end

% get trigger times
if(isempty(opt.trig_times))

    % temporarily use only a single lfp channel
    if(isempty(opt.phase_cdat)||isempty(opt.env_cdat))
        opt.lfp = contchans(opt.lfp,'chanlabels',opt.lfp_chan);
        [opt.lfp_theta,opt.phase_cdat,opt.env_cdat] = gh_theta_filt(opt.lfp);
        eeg_r.raw = opt.lfp;
        eeg_r.theta = opt.lfp_theta;
        eeg_r.phase = opt.phase_cdat;
        eeg_r.env = opt.env_cdat;
    else
        eeg_r.phase = opt.phase_cdat;
        eeg_r.env   = opt.env_cdat;
    end

    if(~isempty(opt.lfp_chan))
        %opt.lfp = contchans_r(opt.lfp,'chans',opt.lfp_chan);
        %opt.phase_cdat = contchans(opt.phase_cdat,'chans',opt.lfp_chan);
        %opt.env_cdat = contchans(opt.env_cdat,'chans',opt.lfp_chan);
        eeg_r = contchans_r(eeg_r,'chanlabels',opt.lfp_chan);
    end

    trigs = gh_troughs_from_phase(eeg_r,'phase',opt.phase);

else
    
    trigs = opt.trig_times;

end


run_bouts = [];
if(opt.min_vel > 0)
    run_bouts = contbouts(pos.lin_vel_cdat,'datargunits','data','thresh_fn',@ge,'thresh',opt.min_vel,'minevdur',diff(crit_range));
elseif(opt.min_vel < 0)
    run_bouts = contbouts(pos.lin_vel_cdat,'datargunits','data','thresh_fn',@le,'thresh',opt.min_vel,'minevdur',diff(crit_range));
end

if(isempty(opt.ok_pos_range))
    opt.ok_pos_range = r_pos_in(1).x_range - opt.pos_range; % hem in whole track by the display pos ammount
else
    opt.ok_pos_range = opt.ok_pos_range - opt.pos_range; % hem in the input restriction by the display pos ammount
end

theta_power_bouts = [];
if(not(isempty(opt.min_theta_power)))
    theta_power_bouts = contbouts(contchans(opt.env_cdat,'chans',1),'datargunits','data','thresh',opt.min_theta_power,'minevdur',diff(crit_range));
end
    
pos_bouts = [];
disp(['ok_pos_range:', num2str(opt.ok_pos_range)]);
from_start_bouts = contbouts(pos.lin_filt,'datargunits','data','thresh_fn',@ge,'thresh',min(opt.ok_pos_range),'minevdur',diff(crit_range));
from_end_bouts = contbouts(pos.lin_filt,'datargunits','data','thresh_fn',@le,'thresh',max(opt.ok_pos_range),'minevdur',diff(crit_range));
pos_bouts = gh_bout_intersect(from_start_bouts,from_end_bouts);

disp('successfully did position');

tmp_bouts = pos_bouts;
tmp_bouts = gh_bout_intersect(tmp_bouts,theta_power_bouts);
tmp_bouts = gh_bout_intersect(tmp_bouts,run_bouts);
%tmp_bouts = gh_bout_intersect(tmp_bouts,pos_bouts);
anal_bouts = tmp_bouts;

if(isempty(anal_bouts))
    warning('gh_triggered_reconstruction:empty_anal_bouts','FOUND NO OK BOUTS FOR SOME REASON.  So, using all triggers');
    anal_bouts = [opt.ok_pos_range(1), opt.ok_pos_range(2)];
end


% hem in the bouts by time_range to remove times with insufficient pre-post
% data
anal_bouts(:,1) = anal_bouts(:,1) - opt.time_range(1);
anal_bouts(:,2) = anal_bouts(:,2) - opt.time_range(2);

keep_ind = (anal_bouts(:,2)-anal_bouts(:,1)) > 0;
n_drop = size(anal_bouts,1) - sum(keep_ind);
anal_bouts = anal_bouts(keep_ind,:);

% filter by bouts
trigs = gh_times_in_timewins(trigs,anal_bouts);


%diff(trigs)

n_tbin_rposin = size(r_pos_in(1).pdf_by_t,2);
n_pos_rposin = size(r_pos_in(1).pdf_by_t,1);
%the_coeff = 1/(1-r_pos_in(1).fraction_overlap)
sec_per_timebin = (r_pos_in(1).tend - r_pos_in(1).tstart)/(n_tbin_rposin);
%sec_per_timebin = sec_per_timebin * the_coeff
meters_per_posbin = diff(r_pos_in(1).x_range)/n_pos_rposin;
n_timebin_before_trig = round(opt.time_range(1) / sec_per_timebin);
n_timebin_after_trig = round(opt.time_range(2) / sec_per_timebin);
n_posbin_toward_start = round(opt.pos_range(1) / meters_per_posbin);
n_posbin_toward_end = round(opt.pos_range(2) / meters_per_posbin);

ts = conttimestamp(pos.lin_filt);
trigs = trigs(trigs > (min(ts) + 10) & trigs < (max(ts)-10));
trigs_t_ind = round( (trigs - r_pos_in(1).tstart) / sec_per_timebin);
y = pos.lin_filt.data;
trigs_p = interp1(ts(~isnan(y)),y(~isnan(y)),trigs);
trigs_p_ind = round( (trigs_p - min(r_pos_in(1).x_range)) / meters_per_posbin);

if(opt.draw)
figure;
ax(1) = subplot(2,1,1);
plot(conttimestamp(pos.lin_filt),pos.lin_filt.data,'-');
hold on
plot(trigs,trigs_p,'o');
ax(2) = subplot(2,1,2);
bouts_cell = cell(0);
bouts_cell{1} = anal_bouts;
bouts_cell{2} = opt.anal_range;
bouts_cell{3} = theta_power_bouts;
bouts_cell{4} = pos_bouts;
bouts_cell{5} = run_bouts;
gh_disp_bouts(bouts_cell);
linkaxes(ax,'x');
end

n_trigs = numel(trigs);
n_tbin_out = n_timebin_after_trig - n_timebin_before_trig + 1;
n_pbin_out = -1*n_posbin_toward_start + n_posbin_toward_end + 1;


for t = 1:numel(r_pos_in)
    
    pdf_matrix = zeros(n_pbin_out,n_tbin_out,n_trigs);
    
    for n = 1:n_trigs
        trigs_t_ind(n);
        trigs_p_ind(n);
        this_pos_ind = (trigs_p_ind(n) + n_posbin_toward_start):(trigs_p_ind(n) + n_posbin_toward_end);
        this_t_ind = (trigs_t_ind(n) + n_timebin_before_trig):(trigs_t_ind(n) + n_timebin_after_trig);
        t;
        n;
        size(pdf_matrix);
        this_pdf = r_pos_in(t).pdf_by_t(this_pos_ind,this_t_ind);
        size(this_pdf);
        pdf_matrix(:,:,n) = this_pdf;
    end
    this_max = max(max(mean(pdf_matrix,3)));
    if(not(opt.normalize_within_chan))
        this_max = 1;
    end
    r_pos_out(t).pdf_by_t = mean(pdf_matrix,3)./this_max;
    r_pos_out(t).x_range = opt.pos_range;
    r_pos_out(t).tstart = opt.time_range(1);
    r_pos_out(t).tend = opt.time_range(2);
    r_pos_out(t).r_tau = r_pos_in(1).r_tau;
    r_pos_out(t).fraction_overlap = r_pos_in(1).fraction_overlap;
r_pos_out(t).color = r_pos_in(t).color;
r_pos_out(t).trodes = r_pos_in(t).trodes;
r_pos_out(t).f_bins = [];
end
