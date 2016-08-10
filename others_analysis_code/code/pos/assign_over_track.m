function track_data = assign_over_track( ts, data, pos_info, track_info, varargin )

% function track_data = assign_over_track( ts, data, pos_info )
%  returns data as a function of track position
%  data is n_params by (numel(ts))
%  track_data is n by numel(track_segments)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('timewins',[]);
p.addParamValue('per_bin_fn', @mean);
p.parse(varargin{:});
opt = p.Results;

% drop timepoints that don't fall in timewins
if( ~isempty(opt.timewin))
    [~,keep_bool] = gh_times_in_timewins( ts, opt.timewin );
    ts = ts(keep_bool);
    data = data(:,keep_bool);
end
if(~isempty(opt.timewins))
    [~,keep_bool] = gh_times_in_timewins( ts, opt.timewins );
    ts = ts(keep_bool);
    data = data(:,keep_bool);
end

tracker_ts = conttimestamp(pos_info.lin_filt);
tracker_p = reshape( pos_info.lin_filt.data, 1, [] );
pos_at_ts = interp1( tracker_ts, tracker_p, ts );

bin_centers = track_info.field_lin_bin_centers;
n_bin_centers = numel( bin_centers );
bin_edges = bin_centers_to_edges( bin_centers );

track_data = zeros( size(data,1), n_bin_centers );

for n = 1:n_bin_centers
    this_bin_edges = [bin_edges(n), bin_edges(n+1)];
    this_track_bin_bool = and( pos_at_ts >= this_bin_edges(1), ...
        pos_at_ts < this_bin_edges(2) );
    this_data = data(:, this_track_bin_bool);
    track_data(:,n) = opt.per_bin_fn( this_data, 2 );
end