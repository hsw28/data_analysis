function eval_tt_files(baseDir, epoch)

day = [18, 22, 23, 24, 28, 22, 24, 25, 26];
ep =  [3,   1,  1,  2,  3,  3,  3,  3,  3];

[en, et] = load_epochs(baseDir);

et = et( strcmp(en, sprintf('sleep%d', epoch) ),:);

et = [et(1), et(2)];

tt_dir = dir(fullfile(baseDir,'t*'));

nTT = numel(tt_dir);

ttList = cell(nTT, 1);


figure;
axes;
tbins = et(1):.01:et(2);
for i = 1 : nTT
    if tt_dir(i).isdir
        ttFile = sprintf('%s/%s/%s.tt', baseDir, tt_dir(i).name, tt_dir(i).name);
        if exist( ttFile, 'file')
            
            
            [~, ts] = import_waveforms_from_tt_file(ttFile, 'idx', [], 'time_range', et);
            
            rate = histc(ts, tbins);
            [xc, lags] = xcorr(rate, 25);
            plot(lags, xc);
            
            title( sprintf('%s', ttFile));
            pause;
            
        end
    end

end