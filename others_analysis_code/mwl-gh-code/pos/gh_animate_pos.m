function h = gh_animate_pos(pos_info, track_info, varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('smooth_sd', 0.06);
p.addParamValue('framerate',30);
p.addParamValue('time_compress',1);
p.parse(varargin{:});
opt = p.Results;

% **************** This whole part should be replaced by ***
% ****** smeared_rat_timecourse() ******

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

frame_dt = 1/opt.framerate;
frame_ts = min(ts) : (frame_dt * opt.time_compress) : max(ts);
n_frames = numel(frame_ts);

if(any(isnan(lin_pos)))
    warning('some NaN in lin_pos');
    lin_pos(isnan(lin_pos)) = 0;
end

frame_pos = interp1(ts,lin_pos,frame_ts,'linear');

% I want 1 time point per row
[TRACK_POS, FRAME_POS] = meshgrid(track_pos, frame_pos);
patch_value = (1/(opt.smooth_sd * sqrt(2*pi))) .* ...
    exp( -1* (FRAME_POS - TRACK_POS).^2 ./ (2 * opt.smooth_sd^2));

% ************************************************

patch_color = zeros( n_frames, n_track_pos, 3);
patch_color(:,:,1) = 0;
patch_color(:,:,2) = patch_value;
patch_color(:,:,3) = patch_value;

patch_color = patch_color ./ max(max(max(patch_color)));

h = patch(track_info.field_patches.x, ...
    track_info.field_patches.y,...
    patch_color(1,:,:));

for n = 2:n_frames
    set(h,'CData',patch_color(n,:,:));
    title(num2str( frame_ts(n)));
    pause(frame_dt);
end

