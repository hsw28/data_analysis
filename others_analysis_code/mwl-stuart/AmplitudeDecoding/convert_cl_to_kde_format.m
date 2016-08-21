function [out ns] = convert_cl_to_kde_format(exp, epoch, varargin)
%CONVERT_CL_TO_KDE_FORMAT converts clusters into the a format that is
%compatible with the poisson KDE decoder
%
% [cl ns] = make_tetrode_maps(exp, epoch)  returns a  cell array of 
% nx8 matrices where columns 1:4 correspond to the spike amplitudes 
% across the 4 tetrode channels, 
%
% column 5 is the timestamp when the spike was recorded
% column 6 is the position at which the spike was recorded
% column 7 is the velocity of the animal when the spike was recorded
% column 8 is the width of the recorded spike
%
% 
% This function differs from LOAD_TETRODES_AMPS in that each cell contains 
% data from a single clusters instead of data from a single tetrode
% 
% see also decode_amplitudes decode_clusters load_tetrode_amps

a.tt_file_fields =  {'timestamp', 'waveform'};
args.time_range = exp.(epoch).et;
args = parseArgsLite(varargin,args);

cl_tt_list = {exp.(epoch).cl.tt};
p = exp.(epoch).pos;

out = cell(size(exp.(epoch).cl));
spikes = {};
widths = {};

for i=1:numel(out)
    disp(['Loading amplitude data for:', exp.(epoch).cl(i).file]);

    idx = exp.(epoch).cl(i).id;
        
    file = fullfile(exp.edir, exp.(epoch).cl(i).tt, [exp.(epoch).cl(i).tt, '.tt']);
    [spikes widths] = load_spike_parameters(file, 'idx',idx, 'time_range', exp.(epoch).et);
    ts = spikes(:,5);
    warning off;
    pos = interp1(p.ts, p.lp, ts, 'nearest');
    vel = interp1(p.ts, p.lv, ts, 'nearest');
    warning on;
    valid_ind = ~isnan(pos);
    valid_ind = valid_ind & ~isnan(vel);
    o = [spikes,pos,vel,widths'];
    out{i} = o(valid_ind,:);
end

end







  
