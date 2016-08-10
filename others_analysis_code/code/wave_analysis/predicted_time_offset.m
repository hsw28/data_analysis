function [prop_delay, opt] = predicted_time_offset( b_model, varargin )
% predicd time offset along septo-temporal axis 
% pass 'anatomical_axis' [x,y] to choose a 'st axis' to use for all time
% otherwise 'best axis' will be determined for each prediction
% epoch by the wave model

p = inputParser();
p.addParamValue('anatomical_axis',[]);
p.parse(varargin{:});
opt = p.Results;

ts = b_model.timestamps;
n_ts = numel(ts);

% How many seconds delay are introduced in the wave
% propagation direction per mm distance separation?
%
% wave propagation speed is  temp_freq * spatial_wavelength
% time delay is spatial_distance / propagation_speed
% so delay = distance / (spatial_wavelength * temp_freq )
% (units:)  sec =  mm / (  mm/cycle * cycle/sec)
prop_delay_best_axis = 1 ./ ( b_model.est(2,:) .* b_model.est(1,:));
prop_best_axis = b_model.est(3,:);

if( ~isempty( opt.anatomical_axis) )
    anatomical_angle = angle( opt.anatomical_axis(1) + i*opt.anatomical_axis(2) );
    prop_delay = prop_delay_best_axis .* cos( anatomical_angle - prop_best_axis );
else
    prop_delay = prop_delay_best_axis;
end