clear; close all;

d = 26;
baseDir = sprintf('/data/gh-rsc2/day%d', d);
ep = 'sleep3';
[en, et] = load_epochs(baseDir);

et = et(strcmp(ep, en),:);
eF = 'k';
fid = mwlopen( sprintf('%s/%s%d.eeg.debuf', baseDir, eF, d) );

d = loadrange(fid, 'all', et, 'timestamp');

%%

ts = d.timestamp;
data = [d.channel1; d.channel2; d.channel3; d.channel4;...
     d.channel5; d.channel6; d.channel7; d.channel8];
 
 line_browser(ts, data', 'offset', 1000);
 set(gcf,'Position', [80 580 1350 750]);
 set(gca,'Position', [.035 .045 .95 .94]);
 
 
 %%
 clear;
 dsets = {...
            {1, 18, 'sleep3', 'k', 5}, ...
            {1, 22, 'sleep1', 'k', 5}, ...
            {1, 23, 'sleep1', 'k', 5}, ...
            {1, 24, 'sleep2', 'k', 5}, ...
            {1, 28, 'sleep3', 'k', 5}, ...
            {2, 22, 'sleep3', 'k', 7}, ...
            {2, 24, 'sleep3', 'k', 7}, ...
            {2, 25, 'sleep3', 'k', 7}, ...
            {2, 26, 'sleep3', 'k', 7}   };
        
        
nD = numel(dsets)
for i = 1:nD
    save_ctx_eeg(dsets{i}{:});
end
        
        