function [r_pos_stack,all_cells_r_pos] = ...
    gh_decode_around_theta_phase(sdat,eeg_r,pos_info,target_phase,trode_groups,varargin)
%GH_DECODE_AROUND_THETA_PHASE compute reconstruction for a single
% timewindow each time theta reaches a specific phase
%
%    Syntax
%
% r_pos_stack =
% gh_decode_around_theta_phase(sdat,cdat,target_phase,['r_tau',0.005,
%                                                      'min_theta_env',0.2]);
%                                                          
%
%    Description
%
% Each time 

p = inputParser();
p.addParamValue('r_timewin',[min(pos_info.timestamp), max(pos_info.timestamp)]);
p.addParamValue('field_direction','outbound');
p.addParamValue('fraction_overlap',0);
p.addParamValue('r_tau', 0.02);         % reconstruction window width
                                        % around each theta trigger
                                        
p.addParamValue('min_theta_env', 0.1);

%pre-computed parts
p.addParamValue('all_cells_r_pos',[]);
p.addParamValue('r_pos_stack',[]);

p.addParamValue('norm_y',false);
p.parse(varargin{:});
opt = p.Results;


phase_times = gh_troughs_from_phase(eeg_r.phase,'phase',target_phase);

% compute the all-units-together reconstruction if not passed in already
if(isempty(opt.all_cells_r_pos))
    opt.all_cells_r_pos = gh_decode_independent_timepoints(sdat,pos_info,phase_times,...
        'field_direction',opt.field_direction,'r_tau',opt.r_tau,'r_timewin',opt.r_timewin);
    
    %opt.all_cells_r_pos = gh_decode_pos(sdat,pos_info,'r_tau',opt.r_tau_all,...
    %    'field_direction',opt.field_direction,'fraction_overlap',opt.fraction_overlap);
end
all_cells_r_pos = opt.all_cells_r_pos;


% compute the single-time-bin grouped reconstructions if not passed in
% already
if(isempty(opt.r_pos_stack));
opt.r_pos_stack = gh_decode_independent_timepoints(sdat,pos_info,phase_times,...
    'field_direction',opt.field_direction,'r_tau',opt.r_tau,...
    'trode_groups',trode_groups,'r_timewin',opt.r_timewin);
r_pos_stack = opt.r_pos_stack;
%return;
end
r_pos_stack = opt.r_pos_stack;

gh_plot_rpos_stack(opt.r_pos_stack,opt.all_cells_r_pos,pos_info,'mode_hist_bins',linspace(-1,1,100),'norm_y',opt.norm_y);
return;