function r_pos_s = gh_decode_independent_timepoints(...
    sdat,pos_info,time_pts,varargin)
%GH_DECODE_INDEPENDENT_TIMEPOINTS Bayesian reconstruction of single
%timewins
%
%   Syntax
% r_pos_stack =
% gh_decode_independent_timepoints(sdat,time_pts,['r_tau',0.01,
%                                                 'field_direction','inbound'
%                                                 'place_field_opts',pf_opt]
%                                                 
%   Description
% Use this function to reconstruct position for a single timewindow.
% For example, to predict instantaneous position given spikes falling
% within 5 ms of theta crossing a given phase

p = inputParser();
p.addParamValue('r_timewin',[]);
p.addParamValue('r_tau', 0.005);
p.addParamValue('field_direction', 'outbound');
p.addParamValue('decode_run_direction_filter',[]);
p.addParamValue('trode_groups',[]);
p.parse(varargin{:});
opt = p.Results;

% first filter time_pts to drop ones not meeting run dir filter
if(strcmp(opt.decode_run_direction_filter, 'outbound'))
    time_pts = gh_times_in_timewins(time_pts,opt.pos_info.out_run_bouts);
elseif(strcmp(opt.decode_run_direction_filter,'inbound'))
    time_pts = gh_times_in_timewins(time_pts,opt.pos_info,in_run_bouts);
end

if(~isempty(opt.r_timewin))
    time_pts = time_pts( time_pts >= min(opt.r_timewin) & time_pts <= max(opt.r_timewin));
end

n_reconst = numel(time_pts);

r_ranges = [time_pts - opt.r_tau/2; time_pts + opt.r_tau/2];

if(isempty(opt.trode_groups))
    opt.trode_groups = cell(1);
    
    %opt.trode_groups{1} = struct('trodes',cell(1,numel(sdat.clust)),'color',[1 1 1]);
    opt.trode_groups{1} = struct();
    for n = 1:numel(sdat.clust)
        opt.trode_groups{1}.trodes{n} = sdat.clust{n}.comp;
    end
    opt.trode_groups{1}.color = [1 1 1];
end

r_pos_s = ...
    decode_pos_with_trode_pos(sdat,pos_info,opt.trode_groups, ...
    'r_tau',opt.r_tau, 'field_direction',opt.field_direction,...
    'r_ranges',r_ranges);
%r_pos_s.track_pos = interp1(conttimestamp(pos_info.lin_cdat),...
%                                       pos_info.lin_cdat.data, ...
%                                       time_pts);
%r_pos_s.trigger_time = time_pts;
