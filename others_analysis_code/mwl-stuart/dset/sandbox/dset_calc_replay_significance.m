function [p] = dset_calc_replay_significance(stats, shuffles, alpha)
    
    if ~isscalar(stats) && isstruct(stats)
        error('Stats must be a single struct');
    end
    
    if ~iscell(shuffles)
        error('Shuffles must be a cell array of shuffle distributions')
    end
    
    
    if nargin<3
        alpha = .05;
    elseif isempty(alpha) || alpha < 0 || alpha > 1 
        error('alpha cannot be empty and must be between 0 and 1');
    end
   
    nShuffleType = numel(shuffles);
    nShuffle = size(shuffles{1},3);
    
    nEvent = size(shuffles{1}, 1);
    
    p = nan(nEvent, nShuffleType);
    
    [~, bestIdx] = max(stats.score2, [], 2);
    
    for iShuffleType = 1:nShuffleType
        for j = 1:nEvent
            p(j, iShuffleType) = 1 - sum( stats.score2(j,bestIdx(j)) > shuffles{iShuffleType}(j,bestIdx(j),:) )  / nShuffle;       
        end
    end


end