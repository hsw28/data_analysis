function [new_sdat, new_pos, new_track] = assign_field(sdat,pos,varargin)

p = inputParser();
p.addParamValue('n_track_seg',100,@(x) x>0);
p.addParamValue('timewin',[]);
p.addParamValue('smooth_sd_segs',[]);
p.addParamValue('track_info',[]);
p.addParamValue('track_to_patches_width',10);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

new_sdat = assign_cdat_to_sdat(sdat,pos.lin_filt,...
    'cdat_bouts',pos.out_run_bouts,'featurename','out_pos_at_spike','cdat_default_chan',1);
new_sdat = assign_cdat_to_sdat(new_sdat,pos.lin_filt,...
    'cdat_bouts',pos.in_run_bouts,'featurename','in_pos_at_spike');
new_sdat = assign_cdat_to_sdat(new_sdat,pos.lin_filt,...
    'cdat_bouts',pos.run_bouts,'featurename','pos_at_spike');
new_sdat = assign_cdat_to_sdat(new_sdat,pos.lin_filt,...
    'cdat_bouts', [pos.lin_filt.tstart,pos.lin_filt.tend],'featurename','pos_at_all_spikes');

new_sdat = assign_cdat_to_sdat(new_sdat,pos.x_filt,...
    'cdat_bouts', [pos.lin_filt.tstart,pos.lin_filt.tend],'featurename','x_at_all_spikes');
new_sdat = assign_cdat_to_sdat(new_sdat,pos.y_filt,...
    'cdat_bouts', [pos.lin_filt.tstart,pos.lin_filt.tend],'featurename','y_at_all_spikes');

if(isempty(opt.timewin))
    opt.timewin = [pos.lin_filt.tstart, pos.lin_filt.tend];
end
pos.lin_filt = contwin(pos.lin_filt,opt.timewin);

pos_ts = conttimestamp(pos.lin_filt);
pos_dt = pos_ts(2)-pos_ts(1);

%track_bin_centers = linspace(0,max(pos.lin_filt.data),opt.n_track_seg);
%track_bin_dt = track_bin_centers(2)-track_bin_centers(1);
%track_bin_edges = [track_bin_centers - track_bin_dt/2, track_bin_centers(end) + track_bin_dt/2];

track_bin_edges = linspace(0,max(pos.lin_filt.data),opt.n_track_seg + 1);
track_bin_dt = track_bin_edges(2) - track_bin_edges(1);
track_bin_centers = track_bin_edges(1:end-1) + track_bin_dt/2;

[pos_times_in_bidirect_bouts,bidirect_logicals] = gh_times_in_timewins(pos_ts,pos.run_bouts);
bidirect_oc = gh_whistc(pos.lin_filt.data',bidirect_logicals,track_bin_edges);
bidirect_oc = bidirect_oc(1:end-1) .* pos_dt; % drop the last bin, count(times == last edge)

[pos_times_in_outbound_bouts,outbound_logicals] = gh_times_in_timewins(pos_ts,pos.out_run_bouts);
outbound_oc = gh_whistc(pos.lin_filt.data',outbound_logicals,track_bin_edges);
outbound_oc = outbound_oc(1:end-1) .* pos_dt; % drop the last bin, count(times == last edge)


[pos_times_in_inbound_bouts,inbound_logicals] = gh_times_in_timewins(pos_ts,pos.in_run_bouts);
inbound_oc = gh_whistc(pos.lin_filt.data',inbound_logicals,track_bin_edges);
inbound_oc = inbound_oc(1:end-1) .* pos_dt; % drop the last bin, count(times == last edge)

if(sum(isnan(outbound_oc)) > 0 || sum(isnan(inbound_oc)) > 0)
    error('assign_field:nan_in_occupancy','Occupancy has nan');
end

% one more series, ignoring velocity
pos_times_all_times = pos_ts;
all_times_logicals = ones(size(inbound_logicals));
all_times_oc = gh_whistc(pos.lin_filt.data',all_times_logicals,track_bin_edges);
all_times_oc = all_times_oc(1:end-1) .* pos_dt;

if(opt.draw)
plot(track_bin_centers,bidirect_oc,'k');
hold on
plot(track_bin_centers,all_times_oc,'k','Linestyle','--');
plot(track_bin_centers,outbound_oc,'b');
plot(track_bin_centers,inbound_oc,'g');
end

pos.occupancy.bin_centers = track_bin_centers;
pos.occupancy.all_times = all_times_oc;
pos.occupancy.bidirect = bidirect_oc;
pos.occupancy.outbound = outbound_oc;
pos.occupancy.inbound = inbound_oc;

new_pos = pos;

n_pos = numel(pos.occupancy.bin_centers);

% My old way of smoothing the fields.  I think it's right but switching to
% fab's smoothn to be safe
%if(isempty(opt.smooth_sd_segs))
%    c_mat = eye(n_pos);
%else
%    real_pos = repmat(track_bin_centers,n_pos,1);
%   dist_mat = real_pos' - real_pos;
%    c_mat = exp(-1.*(dist_mat.^2)./(2*opt.smooth_sd_segs));
%    col_sum = sum(c_mat,1);
%    c_mat = c_mat ./ repmat(col_sum,n_pos,1);
%end
    

for i = 1:numel(sdat.clust)
    this_cl = new_sdat.clust{i};
    counts = histc(this_cl.data(:,gh_dcbn(this_cl,'pos_at_spike')),track_bin_edges);
    counts = counts(1:end-1)' ./ bidirect_oc;
    counts(isnan(counts)) = 0;
    %counts = counts * c_mat;
    
    in_counts = histc(this_cl.data(:,gh_dcbn(this_cl,'in_pos_at_spike')),track_bin_edges);
    in_counts = in_counts(1:end-1)' ./ inbound_oc;
    in_counts(isnan(in_counts)) = 0;
    %in_counts = in_counts * c_mat;
    
    out_counts = histc(this_cl.data(:,gh_dcbn(this_cl,'out_pos_at_spike')),track_bin_edges);
    out_counts = out_counts(1:end-1)' ./ outbound_oc;
    out_counts(isnan(out_counts)) = 0;
    %out_counts = out_counts * c_mat;
    
    new_sdat.clust{i}.field.bin_centers = track_bin_centers;
    
    all_counts = histc(this_cl.data(:,gh_dcbn(this_cl,'pos_at_all_spikes')),track_bin_edges);
    all_counts = all_counts(1:end-1)' ./ all_times_oc;
    %all_counts = all_counts * c_mat;
    
    if(~isempty(opt.smooth_sd_segs))
        disp('smooth_sd_segs seems broken (later note: why?)');
        counts = smoothn(counts,opt.smooth_sd_segs);
        in_counts = smoothn(in_counts,opt.smooth_sd_segs);
        out_counts = smoothn(out_counts,opt.smooth_sd_segs);
        all_counts = smoothn(all_counts,opt.smooth_sd_segs);
    end
    
    new_sdat.clust{i}.field.bidirect_rate = counts;
    new_sdat.clust{i}.field.in_rate = in_counts;
    new_sdat.clust{i}.field.out_rate = out_counts;
    new_sdat.clust{i}.field.all_rate = all_counts;
end
%size(new_sdat.clust{1}.field.bin_edges)
%size(new_sdat.clust{1}.field.bidirect_rate)

if(~isempty(opt.track_info))
    new_track = opt.track_info;
    new_xx = track_bin_centers;
    xx = opt.track_info.xx_os;
    yy = opt.track_info.yy_os;
    %interp1 groups data in columns,
    % transpose x and y to be in columns
    new_yy = interp1(xx', yy', new_xx');
    new_yy = new_yy';
    new_track.field_lin_bin_centers = track_bin_centers;
    new_track.field_xx = new_xx;
    new_track.field_yy = new_yy;
    new_track.field_patches = gh_track_to_patches(new_track.field_yy,...
        'width',opt.track_to_patches_width);
end