function h = lfp_raster_wrt_trode_location(data, trode_x, trode_y, wrt_opt, varargin)
% LFP_RASTER_WRT_TRODE_LOCATIONS.  Only uses trode_x

p = inputParser();
p.parse(varargin{:});
opt = p.Results;

if(~isempty(wrt_opt.timewin))
    data.mua = sdatslice(data.mua,'timewin', wrt_opt.timewin);
    data.eeg = contwin(data.eeg, 'timewin', wrt_opt.timewin);
end

mua_ind = find( cellfun(@(x) strcmp(x.comp, trode_x), data.mua.clust),1);
lfp_ind = find( strcmp( data.lfp.chanlabels, trode_x ), 1 );

trode_xy_lfp = mk_trodexy(data.lfp, wrt_opt.rat_conv_table);
trode_xy_mua = mk_trodexy(data.mua, wrt_opt.rat_conv_table);


% Frame for LFP and raster
lfp_frame_height = diff(wrt_opt.sub_ylim);
mua_frame_ys = [-0.2,0]*lfp_frame_height + wrt_opt.sub_ylim(1);
%h(1) = plot(wrt_opt.sub_xlim(1) * ones(1,2), [mua_frame_ys(1), wrt_opt.sub_ylim(2)]);
hold on;
h(1) = plot(wrt_opt.sub_xlim, wrt_opt.sub_ylim(1)*ones(1,2),'k');
h(2) = plot(wrt_opt.trig_time*ones(1,2), [mua_frame_ys(1), wrt_opt.sub_ylim(2)],'k');


if(~isempty(mua_ind))
    this_c = trode_color(data.mua.clust{mua_ind}.comp, wrt_opt.trode_groups);
    [stimes,~] = gh_times_in_timewins(data.mua.clust{mua_ind}.stimes, wrt_opt.sub_xlim);
    [xs,ys] = gh_raster_points(stimes,'y_range', mua_frame_ys);
    if(~isempty(stimes))
        h(numel(h) + 1) = plot(xs,ys,'Color',this_c);
    end
end

if(~isempty(lfp_ind))
    this_c = trode_color(data.lfp.chanlabels{lfp_ind}, wrt_opt.trode_groups);
    eeg = contwin(contchans(data.lfp,'chans',lfp_ind), wrt_opt.sub_xlim);
    h(numel(h)+1) = plot(conttimestamp(eeg), eeg.data,'Color',this_c);
end


