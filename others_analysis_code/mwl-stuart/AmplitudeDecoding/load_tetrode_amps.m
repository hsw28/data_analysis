function [out tt_list ] = load_tetrode_amps(exp, epoch, varargin)
%MAKE_TETRODE_MAPS creates spike amplitude by position vector for each
%spike in the experiment. 
%
% [spikes tt_id] = make_tetrode_maps(exp, epoch)  returns a  cell array of 
% nx8 matrices where columns 1:4 correspond to the spike amplitudes 
% across the 4 tetrode channels, 
%
% column 5 is the timestamp when the spike was recorded
% column 6 is the position at which the spike was recorded
% column 7 is the velocity of the animal when the spike was recorded
% column 8 is the width of the recorded spike
%
% tt_id is a cell array of tetrode ID's. if tt_id{1} = t01 then the all
% values in spikes{1} come from t01
%
% all tetrodes that have more than 1000 spikes in the specified epoch
% are used, it is up to the user to filter the spikes by
% velocity, minimum number of spikes etc...
%
% see also decode_amplitudes decode_clusters convert_cl_to_kde_format

warning('Use LOAD_EXP_AMPLITUDES instead');

cl_tt_list = {exp.(epoch).cl.tt};
p = exp.(epoch).pos;

tt_list = unique(cl_tt_list);


out = cell(size(unique({exp.(epoch).cl.tt})));

widths = {};

for i=1:numel(out)
    disp(['Loading Amplitude data from tetrode:', tt_list{i}]);
    
    file = fullfile(exp.edir, tt_list{i}, [tt_list{i}, '.tt']);
    [spikes widths] = load_spike_parameters(file, 'idx',[],'time_range', exp.(epoch).et);
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



    
    