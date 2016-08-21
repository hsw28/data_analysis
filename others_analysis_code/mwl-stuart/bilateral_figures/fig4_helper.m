function [results] = fig4_helper(stats, recon)

   
    pdfL = recon

        cor(iPdf,:) = col_corr(pdfL{iPdf}, pdfR{iPdf});

   

    [replayCorr, maxCorInd] = max(cor);
    
    nCol = sum(validIdx);

    shuffleCorr = [];
    for iShuffle = 1 : nShuffle
        corS =[];

        for iPdf = 1:numel(recon.replay{1}.pdf)
            
            pdfShuf = pdfL{iPdf}(:,randsample(nCol, nCol, 1));

            corS(iPdf,:) = col_corr(pdfL{iPdf}, pdfShuf);
            
        end   
        
        ind = sub2ind(size(corS), maxCorInd, 1:size(corS,2));
        shuffleCorr(:, iShuffle) = corS(ind);
    end

    results(iFile).replayCorr = replayCorr;
    results(iFile).shuffleCorr = shuffleCorr;
    results(iFile).description = dset_get_description_string(d);

end

fprintf('\n');


%%

