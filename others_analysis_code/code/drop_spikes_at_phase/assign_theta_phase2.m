function new_sdat = assign_theta_phase2(sdat, eeg_r, varargin)
% new_sdat = ASSIGN_THETA_PHASE2(sdat, eeg_r, ['eeg_transfer_mode','GLOBAL/local/model'],
%    Assign 'theta phase' to each spike in    ['rat_conv_table', conv_table]
%    sdat. Options determine whether to use   ['wave_params', wave_params]
%    global or local theta,                   ['wave_model', wave_model (default: plane wave)]
%                                             ['model_overwrites_all', bool (def: false)])
%    
%    

p = inputParser();
p.addParamValue('eeg_transfer_mode','global',...
    @(x) any(strcmp(x, {'global','local','model'})));
p.addParamValue('rat_conv_table', []);
p.addParamValue('global_chan_ind',1);
p.addParamValue('wave_params', []);
p.addParamValue('wave_model', @plane_wave_model);
p.addParamValue('reconstruct_lfp_samplerate',200);
p.addParamValue('model_overwrites_all',false);
p.parse(varargin{:});
opt = p.Results;


% list names of lfp comps, and units' comps
lfp_comp_list = eeg_r.raw.chanlabels;
unit_comp_list = cellfun( @(x) x.comp, sdat.clust, 'UniformOutput',false);
unit_has_lfp = cellfun( @(x) (any(strcmp(x,lfp_comp_list))), unit_comp_list);

if(strcmp(opt.eeg_transfer_mode,'local') && (~all(unit_has_lfp)))
    error('assign_theta_phase2:improper_eeg_r','eeg_r argument is missing channel data for some units');
end
if(strcmp(opt.eeg_transfer_mode,'model') && ...
        (isempty(opt.wave_params) || isempty (opt.wave_model) || isempty(opt.rat_conv_table)))
    error('assign_theta_phase2:improper_args_for_using_wave_model',...
        'using model transefer mode, you have to pass wave_params, wave_model, and rat_conv_table')
end
    
if(strcmp(opt.eeg_transfer_mode, 'model'))
    eeg_r = build_eeg_for_units(sdat, eeg_r, 'wave_params', opt.wave_params,...
        'wave_model',opt.wave_model,'model_overwrites_all',true);
end

for n = 1:numel(sdat.clust)
 
    phase_feature_ind = find(strcmp(sdat.clust{n}.featurenames, 'theta_phase'),1);
    if(isempty(phase_feature_ind))
        phase_feature_ind = 1 + numel(sdat.clust{n}.featurenames);
    end
    
    if(strcmp(opt.eeg_transfer_mode, 'global') || strcmp(opt.eeg_transfer_mode, 'model'))
        c_ts = conttimestamp(eeg_r.raw);
        c_d = reshape( eeg_r.phase.data(:, opt.global_chan_ind),1,[]);
    end
    if(strcmp(opt.eeg_transfer_mode, 'local'))
        c_ts = conttimestamp(eeg_r.raw);
        c_d_ind = find( strcmp(sdat.clust{n}.comp, eeg_r.raw.chanlabels), 1, 'first');
        c_d = reshape( eeg_r.phase.data(:, c_d_ind), 1, []);
    end

    spike_time_ind = find(strcmp('time', sdat.clust{n}.featurenames),1);
    spiketimes = sdat.clust{n}.data(:,spike_time_ind);
    spike_phase = mod (interp1( c_ts, unwrap(c_d), spiketimes ), (2*pi) );
    
    sdat.clust{n}.data(:,phase_feature_ind) = reshape(spike_phase, [],1);
    sdat.clust{n}.featurenames{phase_feature_ind} = 'theta_phase';

end

new_sdat = sdat;