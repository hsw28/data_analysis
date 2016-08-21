function [amp, lp, lv, ts, pc, ttList] = load_dataset_features(baseDir, nChan)

if ~ischar(baseDir) || ~exist(baseDir, 'dir')
    error('baseDir must be a string and valid directory');
end

klustDir = fullfile(baseDir, 'kKlust');

dsetFile = sprintf('%s/dataset_%dch.mat', klustDir, nChan);
if ~exist(dsetFile, 'file')
    error('dataset file does not exist, has create_dataset_file been called?');
end

in = load(dsetFile);

amp = in.amp;
lp = in.lp;
lv = in.lv;
pc = in.pc;
ts = in.ts;
ttList = in.ttList;

end