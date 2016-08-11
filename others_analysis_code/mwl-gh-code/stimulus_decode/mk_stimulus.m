function stimulus = mk_stimulus_lin_track(varargin)
% MK_STIMULUS Stimulus for stimulus decoding

p = inputParser();
p.addParamValue('pos_info',[]);
p.addParamValue('timewin',[]);
p.addParamValue('samplerate',[]);
p.addParamValue('features', cell(0));
p.addParamValue('var_types',cell(0));
p.parse(varargin{:});

if(isempty(opt.samplerate))
    dt = opt.pos_info.