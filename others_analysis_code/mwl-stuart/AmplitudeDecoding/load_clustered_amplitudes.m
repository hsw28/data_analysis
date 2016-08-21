function [out ttId] = load_clustered_amplitudes(exp, epoch, varargin)
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
args.anti = 0;
args = parseArgsLite(varargin,args);


if logical(args.anti)
    disp('Loading the anti-clusters, this will take some time');
end

cl_tt_list = {exp.(epoch).cl.tt};
p = exp.(epoch).pos;

tt_list = unique(cl_tt_list);


out = cell(size(unique({exp.(epoch).cl.tt})));
spikes = {};
widths = {};

for i=1:numel(out)
    disp(['Loading data from tetrode:', tt_list{i}]);
    cl_tt_ind = find(ismember(cl_tt_list, tt_list(i)));
    idx = [];
    for j=1:numel(cl_tt_ind) % aggregate all the idx for a single tetrode
        cl_n = cl_tt_ind(j);
        id = exp.(epoch).cl(cl_n).id(:);
        idx = [idx; id];%#ok
    end
    
    idx = sort(idx);
    file = fullfile(exp.edir, tt_list{i}, [tt_list{i}, '.tt']);
    [spikes widths] = load_spike_parameters(file, 'idx',idx, 'anti_idx', args.anti, 'time_range', exp.(epoch).et);
    ts = spikes(:,5);
    warning off;
    pos = interp1(p.ts, p.lp, ts, 'nearest');
    vel = interp1(p.ts, p.lv, ts, 'nearest');
    warning on;
    valid_ind = ~isnan(pos);
    valid_ind = valid_ind & ~isnan(vel);
    o = [spikes,pos,vel,widths'];
    out{i} = o(valid_ind,:);
    ttId{i} = tt_list{i};
end

end







  
