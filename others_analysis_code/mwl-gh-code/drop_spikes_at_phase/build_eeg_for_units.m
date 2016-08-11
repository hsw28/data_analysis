function new_cdat_r = build_eeg_for_units(sdat, eeg_r, varargin)
% new_sdat = ASSIGN_THETA_PHASE2(sdat, eeg_r, ['on_missing_eeg', 'model/nearest/interp'],
%    Assign 'theta phase' to each spike in    ['rat_conv_table', conv_table]
%    sdat. Options determine whether to use   ['wave_params', wave_params]
%    global or local theta,                   ['wave_model', wave_model (default: plane wave)]
%                                             ['model_overwrites_all', bool (def: false)])
%    
%    

p = inputParser();
p.addParamValue('eeg_transfer_mode','global',...
    @(x) any(strcmp(x, {'global','local','model'})));
p.addParamValue('on_missing_eeg', 'drop', ...
    @(x) any(strcmp(x, {'model','nearest','interp'})));
p.addParamValue('rat_conv_table', []);
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

% Case 1: Build missing (or all) eeg chans from the model
if(strcmp(opt.on_missing_eeg, 'model'))
    % when user uses 'model' theta, we build eeg_r from scratch
    if(any( [isempty(opt.rat_conv_table), isempty(opt.wave_params), isempty(opt.wave_model)]))
        error('assign_theta_phase2:bad_input_args_for_model',...
            ['Speficying wave model far assign_theta_phase2, you must also pass ',...
            ' ''rat_conv_table'' , ''wave_params'', and ''wave_model'' ']);
    end
    unit_comp_list = unique(unit_comp_list);
    trode_xy = mk_trodexy(sdat, opt.rat_conv_table);
    ts_min = min (cellfun ( @(x) min(x.stimes), sdat.clust) );
    ts_max = max (cellfun ( @(x) max(x.stimes), sdat.clust) );
    dt = 1/opt.reconstruct_lfp_samplerate;
    ts = (ts_min - dt) : dt : (ts_max + dt);
    eeg = eeg_r.raw;
    if(opt.model_overwrites_all)
        eeg.data = [];
        eeg.chanlabels = {};
    else
        if(~isempty(eeg.chanlabels))
            ts = conttimestamp(eeg);
        end
    end
    model_params = interp1(opt.wave_params.timestamps, opt.wave_params.est', ts','nearest');
    for n = 1:numel(sdat.clust)
        if(~unit_has_lfp(n))
            model_x = [ts', repmat(trode_xy(n,1), size(ts')), repmat(trode_xy(n,2), size(ts'))];
            model_data = opt.wave_model( model_params, model_x );
            eeg.chanlabels{end + 1} = sdat.clust{n}.comp;
            eeg.data(:,(end + 1)) = model_data;
        end
    end
    new_cdat = eeg;
    new_cdat_r = prep_eeg_for_regress(eeg);
end

% Case 2: Copy eeg from closest chan
if(strcmp(opt.on_missing_eeg, 'nearest'))
    eeg_trode_xy = mk_trodexy(eeg_r.raw,opt.rat_conv_table);
    unit_trode_xy = mk_trodexy(sdat, opt.rat_conv_table);
    unit_comp_list = unique(unit_comp_list);
    eeg = eeg_r.raw;
    t = lookup_t(opt.rat_conv_table.label, opt.rat_conv_table.data(1,:), opt.rat_conv_table.data);
    for n = 1:numel(unit_comp_list)
        if(~any(strcmp(unit_comp_list{n}, eeg_r.raw.chanlabels)))
            this_trode_xy = [t('brain_ml',unit_comp_list{n}), t('brain_ap', unit_comp_list{n})];
            trode_dist_squared = (unit_trode_xy(1) - eeg_trode_xy(:,1)).^2 +...
                (unit_trode_xy(2) - eeg_trode_xy(:,2)).^2;
            nearest = find (trode_dist_squared == min(trode_dist_squared), 1, 'first');
            eeg.chanlabels{end+1} = unit_comp_list{n};
            eeg.data(:,end+1) = eeg.data(:, nearest);
        end
    end
    new_cdat_r = prep_eeg_for_regress(eeg);
end

