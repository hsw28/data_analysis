function f = staxis_phase_precession_plot(st_array,varargin)

p = inputParser();
p.addParamValue('brain_mm_for_fields',0.5);
p.addParamValue('brain_mm_for_phase', 0.5);
p.addParamValue('field_length_m', 3.6);
p.parse(varargin{:});
opt = p.Results;

f = gcf();

for n = 1:numel(st_array)
    
    x_0 = st_array(n).ml;
    y_0 = st_array(n).ap;
    x_s = opt.brain_mm_for_fields;
    y_s = opt.brain_mm_for_phase ./ (2*pi);
    
    n_fields = size(st_array(n).disp_centers,1);
    
    % draw field axes
    plot( x_0 + [0, 0.5].*opt.brain_mm_for_fields, y_0 * [1 1],'k'); hold on;
    plot( x_0 + [0, 0], y_0 + [-pi, pi] * y_s, 'k');
    plot( x_0 + [0, 0.5].*opt.brain_mm_for_fields, y_0 + [pi,pi]*y_s, '--','Color',[0 0 0]);
    plot( x_0 + [0, 0.5].*opt.brain_mm_for_fields, y_0 + [-pi,-pi]*y_s, '--','Color',[0 0 0]);
    plot( x_0 + [0, 0.5].*opt.brain_mm_for_fields, y_0 + [pi/2,pi/2]*y_s, '--','Color',[0.6 0.6 0.6]);
    plot( x_0 + [0, 0.5].*opt.brain_mm_for_fields, y_0 + [-pi/2,-pi/2]*y_s, '--','Color',[0.6 0.6 0.6]);
    %plot( x_0 + [-1/2, -1/2].*opt.brain_mm_for_fields_x, y_0 + opt.brain_mm_for_fields_y .* [-1/2, 1/2],'k');
    %plot( x_0 + [1/2, 1/2].*opt.brain_mm_for_fields_x, y_0 + opt.brain_mm_for_fields_y .* [-1/2, 1/2],'k');
    
    % draw fields
    for m = 1:n_fields
        plot(x_0 + st_array(n).disp_centers(m,:) .* x_s, y_0 + st_array(n).phase_pref(m,:) .* y_s,'Color',rand(1,3)./2,'LineWidth',2);
    end
    axis equal;
    
end