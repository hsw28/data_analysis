function save_ctx_eeg(anim, day, ep, ef, ch)

baseDir = sprintf('/data/gh-rsc%d/day%d',anim, day);

newFile = fullfile( baseDir, sprintf('EEG_CTX_1500_%s.mat', ep));

if exist(newFile,'file')
    fprintf('%s already exists\n', newFile);
    return;
end


[en, et] = load_epochs(baseDir);

et = et(strcmp(ep, en),:);

fid = mwlopen( sprintf('%s/%s%d.eeg.debuf', baseDir, ef, day) );

flds = {'timestamp', sprintf('channel%d', ch)};
d = loadrange(fid, flds, et, 'timestamp');

ctx.ts = d.timestamp;
ctx.data = double(d.(flds{2})); %#ok

save( newFile, 'ctx');
fprintf('%s saved\n', newFile);
%%
