function opt = spike_mod_opt( varargin )
% opt = SPIKE_MOD_OPT(['keep_by_phase': 'all', 'early_phase', or 'late_phase'],
%                     ['shift_by_wave': 'none','model', or 'phase'],
%                     ['shift_timeframe': 'single_cycle','instantaneous', or 'trial_average']        
%                     ['shift_compensation_fraction', 1],                               
%                     ['eeg_r',eeg_r],                                                       
%                     ['model_params',model_params],   
%                     ['theta_cycle_centers',theta_cycle_centers],
%                     ['theta_bouts', theta_bouts]              
%                                                                               
p = inputParser();
p.addParamValue('keep_by_phase','all', ...
    @(x) any(strcmp(x, {'all','early_phase','late_phase'})));
p.addParamValue('shift_by_wave', 'none', ...
    @(x) any(strcmp(x, {'none','model','phase'})));
p.addParamValue('shift_timeframe', 'single_cycle', ...
    @(x) any(strcmp(x, {'single_cycle','instantaneous','trial_average'})));
p.addParamValue('shift_compensation_fraction',1);
p.addParamValue('eeg_r',[]);
p.addParamValue('model_params',[]);
p.addParamValue('modeled_eeg_r',[]);
p.addParamValue('theta_cycle_centers',[]);
p.addParamValue('theta_bouts',[]);

p.parse(varargin{:});

opt = p.Results;