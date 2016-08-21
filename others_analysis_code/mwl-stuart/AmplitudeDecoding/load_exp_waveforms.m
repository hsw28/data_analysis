function [waves] = load_exp_amplitudes(exp, epoch, varargin)

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

widths = {};

for i=1:numel(tt_list)
    disp(['Loading Amplitude data from tetrode:', tt_list{i}]);
    
    file = fullfile(exp.edir, tt_list{i}, [tt_list{i}, '.tt']);
    [~,~,waves{i}] = load_spike_parameters(file, 'idx',[],'time_range', exp.(epoch).et);
           
end



    
    