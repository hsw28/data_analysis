function pos_by_t = smeared_rat_timecourse(pos_info, track_info, varargin)
% pos_by_t = smeared_rat_timecourse() 

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('smooth_sd', 0.06);
p.addParamValue('time_compress',1);
p.parse(varargin{:});
opt = p.Results;

ts = conttimestamp(pos_info.lin_filt);
lin_pos = pos_info.lin_filt.data';

track_pos = track_info.field_lin_bin_centers;
n_track_pos = numel(track_pos);

if(~isempty(opt.timewin))
    keep_bool = and( ts >= min(opt.timewin),...
        ts <= max(opt.timewin));
    ts = ts(keep_bool);
    lin_pos = lin_pos(keep_bool);
end

if(any(isnan(lin_pos)))
    warning('some NaN in lin_pos');
    lin_pos(isnan(lin_pos)) = 0;
end

% I want 1 time point per row
[TRACK_POS, POS_NOW] = meshgrid(track_pos, lin_pos);
pos_by_t.value = (1/(opt.smooth_sd * sqrt(2*pi))) .* ...
    exp( -1* (POS_NOW - TRACK_POS).^2 ./ (2 * opt.smooth_sd^2));

pos_by_t.ts = ts;