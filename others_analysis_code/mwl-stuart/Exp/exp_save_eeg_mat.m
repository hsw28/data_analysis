function exp_save_eeg_mat(edir)
    
    fprintf('\nSaving eeg .mat file for:%s\n\n', edir);
    fileList = dir( fullfile(edir, '*.buf') );
    newFs = 1500;
    
    for i = 1:numel(fileList)
        inFile = fullfile(edir, fileList(i).name);
        outFile{i} = fullfile(edir, [fileList(i).name(1:end-4), '.', num2str(newFs), '.eeg']);
        
        if ~exist(outFile{i}, 'file');
            fprintf('Debuffering %s...', inFile);
            debuffer_eeg_file(inFile, outFile{i}, 'Fs', newFs);
            fprintf(' DONE! Saved as:%s\n', outFile{i});
        end
    end
    
    clearvars -except outFile edir newFs;
        
    % Load the unbuffered data into memory
    fprintf('Loading the unbuffered data');
    for j = 1:numel(outFile)
        fprintf('.');
        inFile = outFile{j};
        dataIn(j) = load( mwlopen( inFile ) );
    end  
    fprintf('DONE!\n');
    % get the epoch names and times
    [en et] = load_epochs(edir);
        
    
    for i = 1:numel(en)
        if ~any( strcmp( {'sleep', 'sleep1', 'run', 'sleep2', 'run1', 'run2', 'sleep3', 'sleep4'}, en{i}) )
            fprintf( 'Skipping epoch:%s\n', en{i} );
            continue;
        end
        
        doneFile = fullfile(edir, [en{i}, '.1500hz.mat']);
        if ~exist(doneFile, 'file')
            % Define the timestamp/sampling vector             
            ts = et(i,1): 1.000 / newFs : ( et(i,2) - (1.000 / newFs) );

            fprintf('Downsampling for epoch:%s ', en{i});
            % resample each channel at the specified times
            for j = 1:numel(outFile)
                for k = 1:8
                    chanStr = sprintf('channel%d', k);
                    data(j).(chanStr) = interp1( dataIn(j).timestamp(2:end), single( dataIn(j).(chanStr)(2:end) ), ts );
                end
            end
            
            switch numel(outFile)
                case 1
                    eeg = [...
                    data(1).channel1; data(1).channel2; data(1).channel3; data(1).channel4; ...
                    data(1).channel5; data(1).channel6; data(1).channel7; data(1).channel8];
                case 2
                    eeg = [...
                    data(1).channel1; data(1).channel2; data(1).channel3; data(1).channel4; ...
                    data(1).channel5; data(1).channel6; data(1).channel7; data(1).channel8; ...
                    data(2).channel1; data(2).channel2; data(2).channel3; data(2).channel4; ...
                    data(2).channel5; data(2).channel6; data(2).channel7; data(2).channel8];
                case 3
                    eeg = [...
                    data(1).channel1; data(1).channel2; data(1).channel3; data(1).channel4; ...
                    data(1).channel5; data(1).channel6; data(1).channel7; data(1).channel8; ...
                    data(2).channel1; data(2).channel2; data(2).channel3; data(2).channel4; ...
                    data(2).channel5; data(2).channel6; data(2).channel7; data(2).channel8; ...
                    data(3).channel1; data(3).channel2; data(3).channel3; data(3).channel4; ...
                    data(3).channel5; data(3).channel6; data(3).channel7; data(3).channel8];
                case 4
                    eeg = [...
                    data(1).channel1; data(1).channel2; data(1).channel3; data(1).channel4; ...
                    data(1).channel5; data(1).channel6; data(1).channel7; data(1).channel8; ...
                    data(2).channel1; data(2).channel2; data(2).channel3; data(2).channel4; ...
                    data(2).channel5; data(2).channel6; data(2).channel7; data(2).channel8; ...
                    data(3).channel1; data(3).channel2; data(3).channel3; data(3).channel4; ...
                    data(3).channel5; data(3).channel6; data(3).channel7; data(3).channel8; ...
                    data(4).channel1; data(4).channel2; data(4).channel3; data(4).channel4; ...
                    data(4).channel5; data(4).channel6; data(4).channel7; data(4).channel8];
            end
          

            save(doneFile, 'eeg', 'ts');

            fprintf('...done!\n');
        else
            fprintf('EEG for %s already saved!\n', en{i});
        end
    end
    fprintf('\n');

end