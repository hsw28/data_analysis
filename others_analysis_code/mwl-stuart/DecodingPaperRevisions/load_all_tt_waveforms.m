function [T, WF, ttList] = load_all_tt_waveforms(baseDir)

if ~ischar(baseDir) || ~exist(baseDir, 'dir')
    error('baseDir must be a string and valid directory');
end

ep = 'amprun';

tt_dir = dir(fullfile(baseDir,'t*'));


nTT = numel(tt_dir);

ttList = cell(nTT, 1);

for i = 1 : nTT
    if tt_dir(i).isdir
        ttFile = sprintf('%s/%s/%s.tt', baseDir, tt_dir(i).name, tt_dir(i).name);
        if exist( ttFile, 'file')
            ttList{i} = tt_dir(i).name;
        end
    end
end

% remove un used cells due created by the dir command above
ttList = ttList( ~cellfun(@isempty, ttList ));
nTT = numel(ttList);


if numel(ttList) == 0
    error('No .tt files found in %s', baseDir);
end


%out = cell(size(unique({exp.(epoch).cl.tt})));

[en, et] = load_epochs(baseDir);
et = et( strcmp(ep, en), :);

[T, WF] = deal( cell(nTT,1) );

% p = load_exp_pos(edir, epoch);

fprintf('Loading data for:');
for i = 1 : 10%nTT
    
    fprintf('%s ', ttList{i});
    ttFile = sprintf('%s/%s/%s.tt', baseDir, ttList{i}, ttList{i});
%     fprintf('\t%s\n', file);
    [waves, ts] = import_waveforms_from_tt_file(ttFile, 'idx',[],'time_range', et);  

    T{i} = ts';
    WF{i} = waves; 
    
end 

fprintf('\n');

end



    
    