function sl = staxis_stats(st_array,varargin)

p = inputParser();
p.addParamValue('edge_limits',[]);
p.addParamValue('reg_origin',[1.5 -2.3]);
p.addParamValue('reg_angle', -pi/4);
p.parse(varargin{:});
opt = p.Results;

n_trodes = length(st_array);

% drop trodes with 0 fields
keep_list = ones(size(st_array));
for n = 1:n_trodes
    if(isempty(st_array(n).fields))
        keep_list(n) = 0;
    end
end
st_array = st_array(logical(keep_list));
n_trodes = sum(keep_list);

% drop fields too close to the edges
if(~isempty(opt.edge_limits))
    for n = 1:n_trodes
        keep_fields = (st_array(n).fields(:,1) >= opt.edge_limits(1))...
            & (st_array(n).fields(:,2) <= opt.edge_limits(2));
        st_array(n).fields = st_array(n).fields(keep_fields,:);
    end
end

% drop trodes with 0 fields again (in case some were dropped after
% edge_limits filter
keep_list = ones(size(st_array));
for n = 1:n_trodes
    if(isempty(st_array(n).fields))
        keep_list(n) = 0;
    end
end
st_array = st_array(logical(keep_list));
n_trodes = sum(keep_list);

% calculate field_widths and build a unified list of widths and positions
big_list = [];
for n = 1:n_trodes
    this_n_fields = size(st_array(n).fields,1);
    st_array(n).field_widths = diff(st_array(n).fields,[],2);
    %[m,i] = max(st_array(n).field_widths);
    %st_array(n).field_widths = 
    % col1: projected distance   col2: field width  col3: ml    col4: ap
    big_list = [big_list; ...
        [zeros(this_n_fields,1),...
        st_array(n).field_widths,...
        st_array(n).ml*ones(this_n_fields,1),...
        st_array(n).ap*ones(this_n_fields,1)]];
end
n_fields = size(big_list,1);

% calculate within-tetrode variance
for n = 1:n_trodes
    this_n_fields = numel(st_array(n).field_widths);
    within_tetrode_variance(n) = ...
        std(st_array(n).field_widths).*2;
end
mean_within_tetrode_variance = mean(within_tetrode_variance(within_tetrode_variance > 0))
stdev_within_tetrode_variance = std(within_tetrode_variance)
sterr_within_tetrode_variance = stdev_within_tetrode_variance / sqrt(n_trodes-1)

% make the regress vector
reg_pos = [cos(opt.reg_angle), sin(opt.reg_angle)];
big_reg_pos = repmat(reg_pos,n_fields,1);
big_r_len = sqrt( (big_reg_pos(:,1) - opt.reg_origin(1)).^2 + (big_reg_pos(:,2) - opt.reg_origin(2)).^2);

A = [big_list(:,3)-opt.reg_origin(1), big_list(:,4)-opt.reg_origin(2)];  % [ ml_pos, ap_pos ]
B = big_reg_pos;
B_bar = big_r_len;

proj_dist = dot(A,B,2) ./ B_bar;
big_list(:,1) = proj_dist;

% regress field widths against st-axis projected distances
[b,bint,r,r_int,stats] = regress( big_list(:,2), [ ones(size(proj_dist)), proj_dist ] );
figure; plot(proj_dist, big_list(:,2),'o');
sl = b(2);

pre_dat = big_list(:,2);
post_dat = (pre_dat - b(1)) - (b(2) .* proj_dist);
pre_var = std(pre_dat) .*2;
post_var = std(post_dat) .*2;
a = 1;