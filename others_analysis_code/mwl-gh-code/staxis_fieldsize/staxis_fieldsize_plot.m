function f = staxis_fieldsize_plot(st_array,varargin)

p = inputParser();
p.addParamValue('brain_mm_for_fields_x',0.25);
p.addParamValue('brain_mm_for_fields_y', 0.25);
p.addParamValue('field_length_m', 3.6);
p.addParamValue('trode_groups',[]);
p.parse(varargin{:});
opt = p.Results;

f = gcf();

for n = 1:numel(st_array)
    
    x_0 = st_array(n).ml;
    y_0 = st_array(n).ap;
    x_s = opt.brain_mm_for_fields_x;
    
    tmp = size(st_array(n).fields,1);
    n_fields = max(tmp);
    field_edges_y = [y_0 - opt.brain_mm_for_fields_y/2: ...
        opt.brain_mm_for_fields_y/n_fields: ...
        y_0 + opt.brain_mm_for_fields_y/2];
    field_edges_y = linspace(y_0 - opt.brain_mm_for_fields_y/2, y_0 + opt.brain_mm_for_fields_y/7*n_fields, n_fields+2);
    fields_x = st_array(n).fields .* opt.brain_mm_for_fields_x ./ opt.field_length_m  ...
        + x_0 - opt.brain_mm_for_fields_x/2;
    
    n_fields = tmp;
    
    % draw field axes
    plot( x_0 + [-1/2, 1/2].*opt.brain_mm_for_fields_x, y_0 - opt.brain_mm_for_fields_y .* [1/2 1/2],'k'); hold on;
    plot( x_0 + [-1/2, -1/2].*opt.brain_mm_for_fields_x, y_0 + opt.brain_mm_for_fields_y .* [-1/2, 1/2],'k');
    plot( x_0 + [1/2, 1/2].*opt.brain_mm_for_fields_x, y_0 + opt.brain_mm_for_fields_y .* [-1/2, 1/2],'k');
    
    % draw fields
    for m = 1:n_fields
        if(numel(fields_x) > 0)
            if(isempty(opt.trode_groups))
                this_color = [rand(1) rand(1) rand(1)];
            else
                for tg = 1:numel(opt.trode_groups)
                    if(any(strcmp(st_array(n).comp, opt.trode_groups{tg}.trodes)))
                        this_color = opt.trode_groups{tg}.color;
                    end
                end
            end
        patch( [fields_x(m,1), fields_x(m,2), fields_x(m,2), fields_x(m,1)],...
            [field_edges_y(m), field_edges_y(m), field_edges_y(m+1), field_edges_y(m+1)],...
            this_color);
        end
    end
    axis equal;
    
end