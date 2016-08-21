function [score] = dset_calc_replay_tc_shuffle(dset, recon, nshuffle, slope, intercept, clIdx, shuffleType, smooth, addpdf)

% pfEdges = dset.clusters(1).pf_edges;
% 
% %make individual trajectory pdfs
% leftIdx =  [pfEdges(1,1):pfEdges(1,2), pfEdges(2,1):pfEdges(2,2)];
% rightIdx = [pfEdges(1,1):pfEdges(1,2), pfEdges(3,1):pfEdges(3,2)];
% outIdx =   [fliplr(pfEdges(2,1) : pfEdges(2,2)), pfEdges(3,1):pfEdges(3,2) ] ;
% 

if nargin<7
    error('Must provided shuffleType');
elseif ~( shuffleType == 1 || shuffleType == 2 )
    shuffleType
    error('Shuffle type must by 1 or 2');
end


score = zeros(size(dset.mu.bursts,1),3,nshuffle);
wb = my_waitbar(0);


for i = 1:nshuffle
    for k = 1:3
        
        reconTemp = dset_reconstruct(dset.clusters(clIdx), 'time_win', dset.epochTime, 'tau', .025, 'trajectory_type', 'individual', 'shuffle_tuning_curves', shuffleType);   
        
        for j = 1:size(dset.mu.bursts,1)
            tempIdx = recon.tbins >= dset.mu.bursts(j,1) & recon.tbins <= dset.mu.bursts(j,2);
            
            if addpdf == 0 
                pdf = reconTemp.pdf{k};
                score(j,k,i) = compute_line_score(recon.tbins(tempIdx), recon.pbins{k}, pdf(:,tempIdx), [], [], smooth);        
            else
                pdf = normalize( reconTemp.pdf{k} .* recon.pdf{k} );      
                score(j,k,i) = compute_line_score(recon.tbins(tempIdx), recon.pbins{k}, pdf(:,tempIdx), slope(j,k), intercept(j,k), smooth);        
            end
       
        end
    end
%        [~, ~, stats.score(j,1,i)] = est_line_detect(recon.tbins(tempIdx), recon.pbins(leftIdx), pdf(leftIdx,:));
%        [~, ~, stats.score(j,2,i)] = est_line_detect(recon.tbins(tempIdx), recon.pbins(rightIdx), pdf(rightIdx,:));
%        [~, ~, stats.score(j,3,i)] = est_line_detect(recon.tbins(tempIdx), recon.pbins(sort(outIdx)), pdf(outIdx,:));
   wb = my_waitbar(i/nshuffle, wb);

end

end
 