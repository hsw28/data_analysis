function f = fig_intro_phase_offsets(eeg_r, rat_conv_table, demo_chans, varargin)
% Generate the figure in Documents/Papers/TravelingWave/Fig1Sketch A left
% FIG_INTRO_PHASE_OFFSETS(eeg_r, rat_conv_table, demo_chans,...
%   [size (w,h)],[phase_to_hue (fn)])
%  eeg_r
%  rat_conv_table
%  demo_chans: cell array of chan names

p = inputParser();
p.addParamValue('size',[800,500]);
p.addParamValue('xlim',[-5 20]);
p.addParamValue('ylim',[-20 10]);
p.addParamValue('MarkerSize',600);
p.addParamValue('FrontMarkerSize',500);
p.addParamValue('phase_to_hue',@(x) mod(x/(2*pi), 1) );
p.addParamValue('arrows',true);
p.addParamValue('traces_x', [6 10]);
p.addParamValue('traces_y', [-10 0]);
p.addParamValue('trace_spacing', 1);

p.addParamValue('feducials',true);
p.parse(varargin{:});
opt = p.Results;

f = figure('Position',[ 100,100, opt.size(1), opt.size(2) ]);
a = axes('Position',[10 10 400 600 ],'Units','pixels');
xlim(opt.xlim);
ylim(opt.ylim);

draw_trodes(rat_conv_table, 'MarkerSize', opt.MarkerSize, 'filled',true,'trode_labels',eeg_r.raw.chanlabels);


xlim(opt.xlim);
ylim(opt.ylim);