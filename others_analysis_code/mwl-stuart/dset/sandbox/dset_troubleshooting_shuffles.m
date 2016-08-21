clear;
dset = dset_load_all('Bon', 4, 2);

%%

lIdx = strcmp({dset.clusters.hemisphere}, 'left');
rIdx = strcmp({dset.clusters.hemisphere}, 'right');

if sum(lIdx) > sum(rIdx)
    clIdx{1} = lIdx;
    clidx{2} = rIdx;
else
    clIdx{1} = rIdx;
    clIdx{2} = lIdx;
end

bIdx = lIdx | rIdx;

smoothPdf = 0;
%%
%compte the UNILATERAL replay line estimates
clear st re
for i = 1:2
    [st(i) re(i) ] = dset_calc_replay_stats(dset, clIdx{i}, [],[],smoothPdf);
end

%% Do Shuffles
nShuffle = 250;

for i = 1

    [sc{i} nm] = dset_calc_replay_shuffle_scores(...
        dset, re(i), nShuffle, st(i).slope, st(i).intercept, clIdx{i}, [1 1 1 1 0], smoothPdf, 0);

    for n = 1:numel(sc{i})

        plot_dset_recon_shuffle_dist(st(i).score2, sc{i}{n}, [num2str(i), ' : ',nm{n}]);
        set(gcf,'NumberTitle', 'off');
    end
    
end