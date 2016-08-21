function [results] = calc_unilateral_replay_bilateral_pdf_correlation(epoch)

if ~any( strcmp({'run', 'sleep'}, epoch) )
    error('invalid epoch');
end

reconFileList = dset_get_recon_file_list(epoch);
dsetFileList = dset_get_dset_file_list(epoch);


nFile = numel(dsetFileList);
[all.nSpike, all.perSpike, all.score] = deal( {[],[]} );

fprintf('%d Total.  Loading: ', nFile);

for iFile = 1:nFile
    fprintf('\b%d', iFile);
    
    dataIn1 = load(dsetFileList{iFile});
    dataIn2 = load(reconFileList{iFile});
    d = dataIn1.d;
    recon = dataIn2.recon;
    clear dataIn1 dataIn2;
   
    cor = [];

    nSpikeL = sum( recon.replay{1}.spike_counts);
    nSpikeR = sum( recon.replay{2}.spike_counts);
    
    validIdx = nSpikeL > 0 & nSpikeR > 0 & recon.replay{1}.replayIdx' & recon.replay{2}.replayIdx';
   
    nShuffle = 250;

    for iPdf = 1:numel(recon.replay{1}.pdf)

        pdfL{iPdf} = recon.replay{1}.pdf{iPdf}(:, validIdx);
        pdfR{iPdf} = recon.replay{2}.pdf{iPdf}(:, validIdx);

        cor(iPdf,:) = col_corr(pdfL{iPdf}, pdfR{iPdf});

    end

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


