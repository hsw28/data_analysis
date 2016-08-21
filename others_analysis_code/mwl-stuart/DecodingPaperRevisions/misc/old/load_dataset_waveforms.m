function [T, WF, ttList] = load_dataset_waveforms(edir, epoch, varargin)

tt_dir = dir(fullfile(edir,'t*'));

nTT = numel(tt_dir);
nTT = 3;

ttList = repmat({}, 1, nTT);

for i = 1 : nTT
    if tt_dir(i).isdir
        if exist(fullfile(edir, tt_dir(i).name, [tt_dir(i).name, '.tt']))
            ttList{i} = tt_dir(i).name;
        end
    end
end


%out = cell(size(unique({exp.(epoch).cl.tt})));

[en, et] = load_epochs(edir);
et = et( strcmp(epoch, en), :);

[T, WF] = deal({});

% p = load_exp_pos(edir, epoch);

fprintf('Loading data for:');
for i = 1 : nTT
    
    fprintf('%s ', ttList{i});
    file = fullfile(edir, ttList{i}, [ttList{i}, '.tt']);
    [waves, ts] = load_tt_file_waveforms(file, 'idx',[],'time_range', et);  

    T{i} = ts';
    WF{i} = waves; 
    
end 

fprintf('\n');

end



    
    