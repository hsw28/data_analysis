function [shuffleScores, shuffleNames] = dset_calc_replay_shuffle_scores(dset, recon, nShuffle, slope, intercept, clIdx, shufflelist, smooth, addpdf)
if nargin<7 || isempty(shufflelist)
    shufflelist = true(4,1); 
end
shufflelist = logical(shufflelist);

if nargin<8
    smooth = 0;
end

if numel(shufflelist)<4
    error('Invalid shuffle list');
end

shuffleScores = {};
shuffleNames = {};
if shufflelist(1)
    disp('Doing pseudo event shuffle');
    shuffleScores{end+1} = dset_calc_replay_pseudo_shuffle(dset, recon, nShuffle, slope, intercept, smooth, addpdf);
    shuffleNames{end+1} = 'Pseudo Event';
end

if shufflelist(2)
    disp('Doing circular shift shuffle');
    shuffleScores{end+1}  = dset_calc_replay_circ_shift_shuffle(dset, recon, nShuffle, slope, intercept, smooth, addpdf);
    shuffleNames{end+1} = 'Circshift Cols';
end

if shufflelist(3)
    disp('Doing Placefield swap shuffle');
    shuffleScores{end+1} = dset_calc_replay_tc_shuffle(dset, recon, nShuffle, slope, intercept, clIdx, 1, smooth, addpdf);
    shuffleNames{end+1} = 'Placefield Swap';
end

if shufflelist(4)
    disp('Doing Placefield shift shuffle');
    shuffleScores{end+1} = dset_calc_replay_tc_shuffle(dset, recon, nShuffle, slope, intercept, clIdx, 2, smooth, addpdf);
    shuffleNames{end+1} = 'Placefield Shift';
end

if numel(shufflelist)>4 && shufflelist(5)
    disp('Doing null shuffle')
    shuffleScores{end+1} = dset_calc_replay_null_shuffle(dset, recon, nShuffle, slope, intercept, smooth, addpdf);
    shuffleNames{end+1} = 'Null Shuffle';
end
    




% function [stats] = dset_calc_replay_shuffle_stats(dset, reconReal, reconShuff, nshuffle)
% 
% pfEdges = dset.clusters(1).pf_edges;
% 
% %make individual trajectory pdfs
% leftIdx =  [pfEdges(1,1):pfEdges(1,2), pfEdges(2,1):pfEdges(2,2)];
% rightIdx = [pfEdges(1,1):pfEdges(1,2), pfEdges(3,1):pfEdges(3,2)];
% outIdx =   [fliplr(pfEdges(2,1) : pfEdges(2,2)), pfEdges(3,1):pfEdges(3,2) ] ;
% 
% 
% for i = 1:nshuffle
%    for j = 1:size(dset.mu.bursts,1)
%            tempIdx = reconReal.tbins >= dset.mu.bursts(i,1) & reconReal.tbins <= dset.mu.bursts(i,2);
%            shuffIdx = randsample( size(reconShuff.pdf, 2), sum(tempIdx) );
%            pdf = normalize( reconReal.pdf(:,tempIdx) .* reconShuff.pdf(:,shuffIdx) );
% 
%            [~, ~, stats.score(j,1,i)] = est_line_detect(reconReal.tbins(tempIdx), reconReal.pbins(leftIdx), pdf(leftIdx,:));
%            [~, ~, stats.score(j,2,i)] = est_line_detect(reconReal.tbins(tempIdx), reconReal.pbins(rightIdx), pdf(rightIdx,:));
%            [~, ~, stats.score(j,3,i)] = est_line_detect(reconReal.tbins(tempIdx), reconReal.pbins(sort(outIdx)), pdf(outIdx,:));
%        
%    end    
% end
% 
% 
% 
% 
% end
