function [waves] = load_exp_cluster_waveforms(exp, epoch, varargin)

p = exp.(epoch).pos;


cl_list = {exp.(epoch).cl.file};

%out = cell(size(unique({exp.(epoch).cl.tt})));

widths = {};

for i=1:numel(cl_list)
    
    tdir = fileparts(fileparts(cl_list{i}));
    [~, tt] = fileparts(tdir); 
    disp(['Loading Amplitude data from tetrode:', tt]);
    
    file = fullfile(tdir, [tt,'.tt']);
    idx = exp.(epoch).cl(i).id;
    [~,~,waves{i}] = load_spike_parameters(file, 'idx',idx,'time_range', exp.(epoch).et);
           
end



    
    