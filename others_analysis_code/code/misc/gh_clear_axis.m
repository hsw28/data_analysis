function gh_clear_axis(a,varargin)
% GH_CLEAR_AXIS tries to remove axis elements (the white background, text labels)

p = inputParser();
p.addParamValue('clear_background',true);
p.addParamValue('clear_x_axis',true);
p.addParamValue('clear_y_axis',true);
p.addParamValue('clear_bounding_box',true);
p.parse(varargin{:});
opt = p.Results;

if(opt.clear_background && opt.clear_x_axis && ...
        opt.clear_y_axis && opt.clear_bounding_box)
    set(a,'Visible','off');
else
    error('gh_clear_axis:unimplemented',['Haven''t implemented turning off', ...
        ' just some components.']);
end
   