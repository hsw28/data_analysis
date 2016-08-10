function fe = field_extents( place_cells, varargin)
% field_extents(place_cells,[]) find extents of place fields for raster
%
%

p = inputParser();
p.addParamValue('rate_threshold', 5);
p.addParamValue('extent_size_override',[]);
p.addParamValue('max_fields', 10 )
p.addParamValue('trode_groups',[]);
p.addParamValue('run_direction', 'bidirect');
p.parse(varargin{:});
opt = p.Results;

n_cells = numel(place_cells.clust);
fe = struct();

for n = 1:n_cells
    this_fields = place_cells.clust{n}.field;
    this_field_x = place_cells.clust{n}.field.bin_centers;
    if(strcmp('bidirect', opt.run_direction))
           this_field_y = max(this_fields.out_rate, this_fields.in_rate);
    elseif(strcmp('outbound', opt.run_direction))
        this_field_y = this_fields.out_rate;
    elseif(strcmp('inbound',opt.run_direction))
        this_field_y = this_fields.in_rate;
    else
          error('field_extents:unrecognized_run_direction','Unrecognized run direction');
    end
    [this_field_x, this_field_y] = lfun_pad_x_and_y(this_field_x, this_field_y);
    [peak_inds, peak_pos, peak_rate] = lfun_peaks(this_field_x, this_field_y);
    fe(n).trode = place_cells.clust{n}.comp;
    if(isempty(opt.trode_groups))
           fe(n).color = [rand(1), rand(1), rand(1)];
    else
        fe(n).color = [1 1 1]; % error color code
        for m = 1:numel(opt.trode_groups)
            if(any(strcmp(fe(n).trode, opt.trode_groups{m}.trodes)))
                fe(n).color = opt.trode_groups{m}.color;
            end
        end
    end
    fe(n).field_extents = lfun_get_extents(this_field_x, this_field_y, ...
        peak_inds, peak_pos, peak_rate,opt);
    
end



function [x_interp,y_interp] = lfun_pad_x_and_y(x,y)
dx = x(2)-x(1);
x = [min(x) - dx, x, max(x) + dx];
y = [0, y, 0];
n_points = 500;
x_interp =linspace(min(x), max(x), n_points);
y_interp = interp1(x,  y, x_interp );

function [inds,pos,rates] = lfun_peaks(x,y)
% is it greater than previous and (greater or equal from next) ?
local_max = and(y(2:(end-1)) >   y(1:(end-2)), ...
                               y(2:(end-1)) >=y(3:end));
local_max = [false, local_max, false];
inds = find(local_max);
pos =  x(inds);
rates = y(inds);

function field_extents = lfun_get_extents(x,y,peak_ind,peak_pos,peak_rate,opt)
field_extents = [];
n_field_extents = 0;
below_to_above_inds = find( diff( y >= opt.rate_threshold) == 1 ) + 1;
above_to_below_inds = find( diff( y >= opt.rate_threshold) ==-1);

while( and(any(peak_rate > opt.rate_threshold), n_field_extents < opt.max_fields ))
    highest_ind = peak_ind(find( peak_rate == max(peak_rate)));
    this_extents = [1,1];
    valid_below_to_above = below_to_above_inds(below_to_above_inds <= highest_ind);
    valid_above_to_below = above_to_below_inds(above_to_below_inds >= highest_ind);
    this_extents(1) = x ( max( valid_below_to_above) );
    this_extents(2) = x ( min( valid_above_to_below) );
    ind_needs_removal = and( x(peak_ind) >= this_extents(1), x(peak_ind) <= this_extents(2));
    peak_ind = peak_ind( ~ind_needs_removal);
    peak_pos = peak_pos( ~ind_needs_removal);
    peak_rate = peak_rate( ~ind_needs_removal);
    if(~isempty(opt.extent_size_override))
        this_extents = x(highest_ind) + opt.extent_size_override .* [-1/2, 1/2];
    end
    field_extents = [field_extents; this_extents];
    n_field_extents = size(field_extents,1);
   % disp('ok');
end
    
    