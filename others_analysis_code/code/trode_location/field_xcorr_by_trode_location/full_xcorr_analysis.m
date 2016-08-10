function [X_reg, y_reg, field_dists, anatomical_dists, xcorr_dists, field_cells, fields, xcorr_r, xcorr_mat, lags, okPairs, f] = full_xcorr_analysis(d,m, varargin)

p = inputParser();

%general options
p.addParamValue('draw',true);
p.addParamValue('zero_diagonal',true);
p.addParamValue('ok_directions',{'outbound','inbound'});

%options for field_dists
p.addParamValue('field_dists',[]);
p.addParamValue('method','peak');
p.addParamValue('field_direction',''); % don't use
p.addParamValue('min_peak_rate_thresh',15);
p.addParamValue('rate_thresh_for_multipeak', 5);
p.addParamValue('multipeak_max_spacing', 0.3);
p.addParamValue('max_abs_field_dist', 0.5);
p.addParamValue('smooth_field_m_sd',0.1);
p.addParamValue('min_boundary_edge_dist',[]);
p.addParamValue('min_peak_edge_dist',0);

%options for xcorr_dists
p.addParamValue('xcorr_dists',[]);
p.addParamValue('xcorr_r',[]);
p.addParamValue('timebouts', []);
p.addParamValue('xcorr_bin_size', 0.002);
p.addParamValue('xcorr_lag_limits', [-0.1, 0.1]);
p.addParamValue('smooth_timewin', 0.01);
p.addParamValue('r_thresh', 5e-2);

% options for anatomiacal_dists
p.addParamValue('anatomical_dists',[]);  %pass this to bypass computing it in full_xcorr_anal
p.addParamValue('ok_areas',[]); % don't use!
p.addParamValue('ok_pair',[]);
p.addParamValue('axis_vector',[1, 0]);
p.addParamValue('anatomical_groups',false);
p.addParamValue('trode_groups',[]);

p.parse(varargin{:});
opt = p.Results;

checkParams(opt);

place_cells    = d.spikes;
pos_info       = d.pos_info;
rat_conv_table = d.rat_conv_table;

if(isempty(opt.ok_pair))
    error('full_xcorr_analysis:unset_ok_pair',...
        'Must specify ''ok_pairs'' field, usually as  ''CA3,CA1'', ''CA1,CA1'', or ''any,any'' ');
end


track_len = max(d.pos_info.interp_lin) - min(d.pos_info.interp_lin);
n_seg = 100;
smooth_segs = opt.smooth_field_m_sd * n_seg / track_len; % TODO: Is this right?
place_cells = assign_field(place_cells,pos_info,'smooth_sd_segs',smooth_segs,'n_track_seg',n_seg);
[fields,field_cells] = get_fields(place_cells, 'method', opt.method, ...
        'min_peak_rate_thresh', opt.min_peak_rate_thresh, 'rate_thresh_for_multipeak',opt.rate_thresh_for_multipeak,...
        'multipeak_max_spacing', opt.multipeak_max_spacing, 'max_abs_field_dist', opt.max_abs_field_dist,...
        'ok_directions',opt.ok_directions);

fieldClusts = place_cells_index_by_field(place_cells,field_cells);
place_cells.clust = fieldClusts;

groups = cmap(@(x) group_of_trode(d.trode_groups,x(6:7)), field_cells);
groups = cmap(@(x) x(1).name, groups);

okPairs = zeros(numel(field_cells), numel(field_cells));
for m = 1:numel(field_cells)
    for n = 1:numel(field_cells)
        if strcmp(opt.ok_pair, [groups{m},',',groups{n}]) || strcmp(opt.ok_pair,'any,any')
            okPairs(m,n) = 1;
        elseif strcmp(opt.ok_pair,[groups{n},',',groups{m}])
            okPairs(m,n) = 0;
        else
            okPairs(m,n) = 0;
        end
        if opt.zero_diagonal && (m == n)
            okPairs(m,n) = 0;
        end
        if strcmp(groups{m},groups{n}) && m > n
            okPairs(m,n) = 0;
        end
    end
end

%********************* Field Distances **********************
if(~isempty(opt.field_dists))
    field_dists = opt.field_dists;
else
    d.spikes.clusts = fieldClusts;
    field_dists = get_field_dists(field_cells,fields,fieldClusts,'okMatrix',okPairs);
end

%field_dists(~okPairs) = NaN;

%************** Time Crosscorrelations *******************
if(~isempty(opt.xcorr_dists))
    xcorr_dists = opt.xcorr_dists;
else
    if(and( isempty(opt.timebouts), ~isempty(opt.field_direction)))
        if(strcmp(opt.field_direction,'outbound'))
            error('full_xcorr_analysis:run_specific','Specifying a field direction is depricated.');
            opt.timebouts = pos_info.out_run_bouts;
        elseif(strcmp(opt.field_direction,'inbound'))
            error('full_xcorr_analysis:run_specific','Specifying a field direction is depricated.');
            opt.timebouts = pos_info.in_run_bouts;
        end
    elseif(isempty(opt.timebouts))
        xcorr_timebouts = [pos_info.out_run_bouts; pos_info.in_run_bouts];
    end
    [xcorr_dists, opt.xcorr_r, xcorr_mat,lags] = ...
        get_xcorr_dists(fieldClusts,field_cells, fields, d, 'timebouts', xcorr_timebouts, ...
        'xcorr_bin_size', opt.xcorr_bin_size,...
        'xcorr_lag_limits', opt.xcorr_lag_limits, 'r_thresh', opt.r_thresh,...
        'field_dists', field_dists, 'smooth_timewin', opt.smooth_timewin);
    goodR = opt.xcorr_r >= opt.r_thresh;
    xcorr_dists(~goodR) = NaN;
    opt.xcorr_r(~goodR) = NaN;
    opt.xcorr_mat(~goodR) = NaN;
    
end

if(~isempty(opt.xcorr_r))
    xcorr_r = opt.xcorr_r;
else
    xcorr_r = [];
end

n_ok_xcorr_pairs = sum(sum(~isnan(xcorr_dists)))/2

if(~isempty(opt.anatomical_dists))
    anatomical_dists = opt.anatomical_dists;
elseif(~opt.anatomical_groups)
    anatomical_dists = get_anatomical_dists(place_cells, field_cells, rat_conv_table, 'axis_vector', opt.axis_vector);
elseif(opt.anatomical_groups)
    if isempty(opt.trode_groups)
          error('full_xcorr_analysis:need_trode_groups',...
              'need to pass trode_groups param to use anatomical_groups option');
    end
    anatomical_dists = get_anatomical_region_dists(fieldClusts, field_cells, opt.trode_groups);
end

if(~opt.anatomical_groups)
[f, X_reg, y_reg] = plot_all_dists(field_dists, xcorr_dists, anatomical_dists,...
    'xcorr_r', opt.xcorr_r,'draw',opt.draw);
end

if(opt.anatomical_groups)
  pairColorMap = containers.Map;
  for n = 1:numel(opt.ok_pairs)
    pairColorMap([opt.ok_pairs{n}{1},'|',opt.ok_pairs{n}{2}]) = gh_colors(n+1);
  end
  plot_all_dists_by_group(field_dists,anatomical_dists,xcorr_dists,...
    field_cells,opt.trode_groups,pairColorMap);
  X_reg = 2;
  y_reg = 2;
end

end


function checkParams(opt)

if iscell(opt.ok_pair)
    error('full_xcorr_analysis:bad_okPairs_param','Pass one okPairs like: ''ca3,ca1'' ');
end

if find( opt.ok_pair == ',') == []
    error('full_xcorr_analysis:bad_okPairs_param','Pass one okPairs like: ''ca3,ca1'' ');
end

end

function p = toPair(pairString)
  commaInd = find(pairString == ',',1,'first');
  if (isempty(commaInd) || commaInd >= numel(pairString))
      error('full_xcorr_analysis:toPair',['Pair name not ok: ', pairString]);
  end
  p{1} = pairString(1:(commaInd-1));
  p{2} = pairString((commaInd+1):end);
end

function p = flipPair(pair)
p = pair;
p{2} = pair{1};
p{1} = pair{2};
end

function b = pairEq(pairA,pairB)
b = strcmp(pairA{1},pairB{1}) && strcmp(pairA{2},pairB{2});
end