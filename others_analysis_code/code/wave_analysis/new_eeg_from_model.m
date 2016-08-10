function new_eeg = new_eeg_from_model(eeg_r, model_params, rat_conv_table, varargin)
% new_eeg_r = NEW_EEG_FROM_MODEL(eeg_r, model_params, rat_conv_table, ['draw',false])
%   Build up what looks like an sdat eeg trace, but built
%   from the regression.
p = inputParser();
p.addParamValue('place_cells',[]);
p.addParamValue('overwrite_existing',true);
p.addParamValue('trial_average',false);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

new_eeg = eeg_r;
chanlabels = eeg_r.raw.chanlabels;

ts = conttimestamp(new_eeg.raw);

if(isempty(p.Results.place_cells)) 
    if(~opt.overwrite_existing)
        error('new_eeg_from_model:incombatible_args","new_eeg_from_model, if you don''t overwrite_existing, then you must pass place_cells');
    end
    % then we build for the channels in the eeg
    n_chans = size(new_eeg.raw.data, 2);
    trode_xy = mk_trodexy(new_eeg.raw,rat_conv_table);
elseif(~isempty(p.Results.place_cells))
    % then we build for the channels in the sdat
    unique_place_cells = sdat_keep_one_cell_per_trode(p.Results.place_cells);
    if(~opt.overwrite_existing)
        drop_bool = cellfun(@(x) any(strcmp(x.comp, eeg_r.raw.chanlabels)), unique_place_cells.clust);
        unique_place_cells.clust = unique_place_cells.clust(~drop_bool);
        if(numel(unique_place_cells.clust) == 0)
            error('new_eeg_from_model:no_unrepresented_place_cells','You asked for place_cell eeg modeling with no overwrites, but all place cells are represented in eeg_r already.');
        end
    end
    n_chans = numel(unique_place_cells.clust);
    trode_xy = mk_trodexy(unique_place_cells, rat_conv_table);
    chanlabels = cellfun( @(x) x.comp, unique_place_cells.clust,'UniformOutput',false);
    %new_eeg.chanlabels = chanlabels;
end

    
model_data = ones(numel(ts),5);
for n = 1:5
    model_data(:,n) = reshape( interp1(model_params.timestamps, model_params.est(n,:), ts, 'nearest'), [], 1);
end

new_eeg.raw.data = zeros( size(new_eeg.raw.data,1), n_chans );
if(~opt.trial_average)
    for n = 1 : n_chans
        this_x = [ reshape(ts,[],1), repmat( trode_xy(n,:), numel(ts), 1)];
        y_hat = plane_wave_model(model_data, this_x);
        new_eeg.raw.data(:,n) = reshape(y_hat,[],1);
    end
    new_eeg.raw.data( isnan(new_eeg.raw.data) ) = 0;
    new_eeg.raw.chanlabels = chanlabels;
    new_eeg = prep_eeg_for_regress(new_eeg.raw);
end

if(opt.trial_average)
    % Find each channel's phase offset.
    % The 'cycle distance' of tetrode wrt traveling wave is the projection
    % length of vector origin->trode onto the vector origin->next wavefront
    trode_x = trode_xy(:,1)';
    trode_y = trode_xy(:,2)';
    vec_t = trode_x + 1i * trode_y;
    abs_t = sqrt( trode_x .^2 + trode_y .^2 );
    
    w = model_data(:,2);
    w(isnan(w)) = [];
    w( w > 100 ) = [];
    model_wavelength = mean(w);
    d = model_data(:,3);
    model_prop_direction = gh_circular_mean(d(~isnan(d)),'dim',1);
    vec_wave = model_wavelength .* exp( 1i .* model_prop_direction );
    
    cos_difference = cos (bsxfun( @minus, angle(vec_t), angle(vec_wave) ) );
    
    % proj A->B = |A| cos ( arg(A) - arg(B) )
    cycle_distance = bsxfun(@times, abs_t, cos_difference) ./ abs(vec_wave);  
    instantaneous_phase_offset = cycle_distance * 2 * pi;
    
    %drop rows with NaN in any column
    instantaneous_phase_offset = instantaneous_phase_offset( ~sum(isnan(instantaneous_phase_offset),2), :);    
    
    mean_phase_offset_accross_trodes = mean(instantaneous_phase_offset);
    
    %normalize phase offsets against the mean
    instantaneous_phase_offset = bsxfun( @minus, instantaneous_phase_offset, mean_phase_offset_accross_trodes );
    
    %take trial averages
    trial_avg_phase_offset = gh_circular_mean( instantaneous_phase_offset, 'dim', 1, 'output_range', [-pi,pi] );
    

    
    baseline_phase = gh_circular_mean(eeg_r.phase.data,'dim',2);
    
    current_phase = bsxfun( @minus, baseline_phase, trial_avg_phase_offset );
    current_phase = mod(current_phase, (2*pi));
    current_phase = gh_circular_subtract( current_phase, 0, 'output_range', [-pi, pi]);
    
    new_eeg.phase.data = current_phase;
    new_eeg.env.data   = mean(mean(eeg_r.env.data(~isnan(eeg_r.env.data)))) * ones(size(current_phase));
    new_eeg.theta.data = real (new_eeg.env.data .* exp( 1i .* current_phase ) );
    new_eeg.raw = new_eeg.theta;
    
    new_eeg.raw.chanlabels = chanlabels;
    new_eeg.theta.chanlabels = chanlabels;
    new_eeg.phase.chanlabels = chanlabels;
    new_eeg.env.chanlabels = chanlabels;
    
    if(opt.draw)
        scatter( trode_x, trode_y, 200, [(trial_avg_phase_offset+pi)/(2*pi);  zeros(size(trode_x));...
            1 - (trial_avg_phase_offset+pi)/(2*pi)]','filled' );
    end
    
end
    
if(~opt.overwrite_existing)
    new_eeg.raw.chanlabels = [new_eeg.raw.chanlabels, eeg_r.raw.chanlabels];
    new_eeg.raw.data =   [new_eeg.raw.data, eeg_r.raw.data];
    new_eeg.theta.chanlabels = [new_eeg.theta.chanlabels, eeg_r.theta.chanlabels];
    new_eeg.theta.data = [new_eeg.theta.data, eeg_r.theta.data];
    new_eeg.env.chanlabels = [new_eeg.env.chanlabels, eeg_r.env.chanlabels];
    new_eeg.env.data   = [new_eeg.env.data,   eeg_r.env.data];
    new_eeg.phase.chanlabels = [new_eeg.phase.chanlabels, eeg_r.phase.chanlabels];
    new_eeg.phase.data = [new_eeg.phase.data, eeg_r.phase.data];
end
    
