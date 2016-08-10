function c = seg_criterion(varargin)
% c = SEG_CRITERION(varargin) signal segmentation criterion
% Properties: name, peak_min, cutoff_value, thresh_is_positive,
%             min_width_pre_bridge, bridge_max_gap, min_width_post_bridge

p = inputParser();
p.addParamValue('name','epoch');
p.addParamValue('peak_min',[], @(x) isnumeric(x));
p.addParamValue('cutoff_value',[]);
p.addParamValue('thresh_is_positive',true);
% p.addParamValue('cutoff_slope',[]);
p.addParamValue('min_width_pre_bridge',0);
p.addParamValue('bridge_max_gap',0);
% p.addParamValue('bridge_max_n',[]); % meaning?
p.addParamValue('min_width_post_bridge',0);
p.parse(varargin{:});

c = p.Results;