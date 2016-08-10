function plot_eeg_and_mua (eeg, mua, trode_groups, varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('spacing',[]);
p.addParamValue('zero_x',false);
p.addParamValue('font_size',22);
p.addParamValue('eeg_chan_inds',[]);
p.parse(varargin{:});
opt = p.Results;

ax(1) = subplot(2,1,1);
sdat_raster(mua, 'timewin', opt.timewin, 'trode_groups', trode_groups,...
    'draw_x_ticks',false,'draw_y_ticks',false);
set(gca,'Position',[0.13 0.665, 0.775, 0.26]);

if(~isempty(opt.eeg_chan_inds))
    eeg = contchans(eeg,'chans',opt.eeg_chan_inds);
end

ax(2) = subplot(2,1,2);
plot_eeg_fn = @(s) gh_plot_cont(eeg,'timewin',opt.timewin,'trode_groups',trode_groups,...
				'font_size',18,'draw_y_ticks',false, s{:});

if(isempty(opt.spacing))
  plot_eeg_fn( cell(0) );
 else
   plot_eeg_fn( {'spacing',opt.spacing} );
end

% gh_plot_cont(eeg, 'timewin', opt.timewin, 'trode_groups', trode_groups, ...
%  	     'font_size',18,'draw_y_ticks',false,);
set(gca,'Position',[0.13, 0.11, 0.775, 0.536]);

linkaxes(ax,'x');

a = 1;
