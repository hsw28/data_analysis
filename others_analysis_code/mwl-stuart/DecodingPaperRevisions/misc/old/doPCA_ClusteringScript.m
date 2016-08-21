
%% Load Data
clear
ep = 'amprun';
dTypes = {'pos'};

edir{1} = '/data/spl11/day13';
edir{2} = '/data/spl11/day14';
edir{3} = '/data/spl11/day15';
edir{4} = '/data/spl11/day16';
edir{5} = '/data/jun/rat1/day01';
edir{6} = '/data/jun/rat1/day02';
edir{7} = '/data/jun/rat2/day01';
edir{8} = '/data/jun/rat2/day02';
edir{9} = '/data/greg/esm/day01';
edir{10}= '/data/greg/esm/day02';
edir{11}= '/data/greg/saturn/day02';
edir{12}= '/data/fabian/fk11/day08';

open_pool;


for i = 12
    fprintf('\n---------- %s ----------\n', upper(edir{i}))
    autoClusterPCAExp(edir{i}, 1);
    autoClusterPCAExp(edir{i}, 4);
end
% 
% for i = 1:12
%      fprintf('\n---------- %s ----------\n', upper(edir{i}))
%      for ii = 1:18
%      	computeClusterXCorr(edir{i}, ii);
%      end
% end

% %%
% close all;
% for i = 1:12
%     plotClusters(edir{i})
% end