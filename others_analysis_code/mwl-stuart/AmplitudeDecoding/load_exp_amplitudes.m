function [out tt_list ] = load_exp_amplitudes(exp, epoch, varargin)
%MAKE_TETRODE_MAPS creates spike amplitude by position vector for each
%tetrode in the experiment. 
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


p = exp.(epoch).pos;

tt_dir = dir(fullfile(exp.edir,'t*'));
tt_list = {};

for i=1:numel(tt_dir)
    if tt_dir(i).isdir
        if exist(fullfile(exp.edir, tt_dir(i).name, [tt_dir(i).name, '.tt']))
            tt_list{end+1} = tt_dir(i).name;
        end
    end
end

%out = cell(size(unique({exp.(epoch).cl.tt})));


for i=1:numel(tt_list)
%     disp(['Loading Amplitude data from tetrode:', tt_list{i}]);
    
    file = fullfile(exp.edir, tt_list{i}, [tt_list{i}, '.tt']);
%     [spikes widths] = load_spike_parameters(file, 'idx',[],'time_range', exp.(epoch).et);
    [~, ts, pk, w] = load_tt_waveforms(file, 'idx',[],'time_range', exp.(epoch).et);
%     ts = spikes(:,5);
    warning off;
    pos = interp1(p.ts, p.lp, ts, 'nearest');
    vel = interp1(p.ts, p.lv, ts, 'nearest');
    warning on;
    
    validIdx = ~isnan(pos) & ~isnan(vel);
    
    o = [pk',ts',pos',vel',w'];
    out{i} = o(validIdx,:);
    
end 
       
end



    
    