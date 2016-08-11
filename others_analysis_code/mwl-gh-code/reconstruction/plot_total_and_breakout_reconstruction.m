function f = plot_total_and_breakout_reconstruction(sdat,pos,varargin)

p = inputParser();
p.addParamValue('r_timewin',[],@isreal);
p.addParamValue('f_timewin',[],@isreal);
p.addParamValue('n_track_seg',50,@isreal);
p.addParamValue('r_tau',0.01,@isreal);
p.addParamValue('field_direction','bidirect');
p.parse(varargin{:});
opt = p.Results;

ax(1) = subplot(2,1,1);
r_pos = gh_decode_pos(sdat,pos,varargin{:});
plot_r_pos(r_pos,pos,'color','gray');

ax(2) = subplot(2,1,2);
r_pos_array = decode_pos_with_trode_pos(sdat,pos,varargin{:});
plot_multi_r_pos(r_pos_array,pos);

linkaxes(ax,'x');