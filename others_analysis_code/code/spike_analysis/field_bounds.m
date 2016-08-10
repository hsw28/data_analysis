function [bs,opt] = field_bounds(clust, varargin)
% [bs,opt] = FIELD_BOUNDS(clust, ['run_direction','biridect',]
%                                ['min_peak_rate', 10,]
%                                ['edge_rate',1],['min_field_width',.25,]
%                                ['use_precomputed_fields',true,]
%                                ['max_n_fields',Inf,]
%                                ['circular_track',false])
% Return the track limits of place fields.  Outbound limits, fields in
% columns
% Outbound fields have bs(1) < bs(2), inbound has bs(1) > bs(2)

p = inputParser();
p.addParamValue('run_direction','bidirect',@(x) any(strcmp(x,{'bidirect','inbound','outbound'})));
p.addParamValue('min_peak_rate', 15);
p.addParamValue('edge_rate',1);
p.addParamValue('min_field_width',0.25)
p.addParamValue('use_precomputed_fields',true);
p.addParamValue('max_n_fields',Inf);
p.addParamValue('min_dist_from_edge',0.2);
p.addParamValue('track_extents',[0 3.6]);
p.addParamValue('circular_track',false);
p.parse(varargin{:});
opt = p.Results;

if (~opt.use_precomputed_fields)
    error('field_bounds:new_fields_unimplemented','non-precomputed fields not implemented');
else
    ps = clust.field.bin_centers;
    rs_out = clust.field.out_rate;
    rs_in = clust.field.in_rate;
    if(opt.circular_track)
        dp = ps(2)-ps(1);
        ps = [ps, ps + max(ps) + dp];
        rs_out = [rs_out, rs_out];
        rs_in = [rs_in, rs_in];
    end
    outbound_peaks = bounds_scan(ps, rs_out, opt);
    inbound_peaks =  bounds_scan(ps, rs_in, opt);
    
    tmp_var = inbound_peaks;
    inbound_peaks(1,:) = tmp_var(2,:); % swap the edges, so inbound fields first element
    inbound_peaks(2,:) = tmp_var(1,:); % is 'further down' the track
    
    if(strcmp(opt.run_direction, 'bidirect'))
        bs = [outbound_peaks, inbound_peaks];
    elseif(strcmp(opt.run_direction,'outbound'))
        bs = outbound_peaks;
    elseif(strcmp(opt.run_direction,'inbound'))
        bs = inbound_peaks;
    else
        error('field_bounds:unsupported_ret_val',['Couldn''t return for run_direction: ',opt.run_direction]);
    end
    
end

if(~isempty(opt.min_dist_from_edge) && ~isempty(bs))
    ok_bool = abs(bs - opt.track_extents(1)) > opt.min_dist_from_edge & ...
              abs(bs - opt.track_extents(2)) > opt.min_dist_from_edge;
    ok_bool = min(ok_bool,[],1);
    bs = bs(:,ok_bool);
end

end

function bounds = bounds_scan(xs,ys,opt) 
    start_inds = find ([ys(1) >= opt.edge_rate, diff(ys >= opt.edge_rate) == 1]);
    stop_inds  = find ([diff(ys >= opt.edge_rate) == -1, ys(end) >= opt.edge_rate]);
    if(opt.circular_track)
        start_ok = start_inds < floor(numel(xs)/2) ;
        start_inds = start_inds(start_ok);
        stop_inds = stop_inds(start_ok);
    end
    assert (numel(start_inds) == numel(stop_inds));
    is_over_thresh = ys >= opt.min_peak_rate;
    is_field = zeros(1,numel(start_inds));
    for n = 1:(numel(start_inds))
        is_field(n) = any(is_over_thresh( (start_inds(n)) : (stop_inds(n)) ));
    end
    bounds = zeros(2,sum(is_field));
    if(sum(is_field > 0))
        bounds(1,:) = xs(start_inds(logical(is_field)));
        bounds(2,:) = xs(stop_inds(logical(is_field)));
        bounds = bounds(:, abs(diff(bounds)) >= opt.min_field_width );
    end
    if(opt.circular_track && numel(bounds) > 0)
        %circular tracks get xs and ys repeated before passing to this fn,
        %so we keep bounds that straddle the seam, keeping the central one
        if(bounds(1,1) == xs(1) && bounds(2,end) == xs(end))
            bounds(:,[1,end]) = [];
        end
        %drop the bounds contained entirely in the replicated zone
        track_max = xs( floor(numel(xs)/2) );
        bounds( :, bounds(1,:) > track_max & bounds(2,:) > track_max) = [];
    end
end

