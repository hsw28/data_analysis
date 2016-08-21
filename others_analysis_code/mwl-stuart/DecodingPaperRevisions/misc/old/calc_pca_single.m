function d = calc_pca_single(wf)
    
    if ndims(wf)<3
    
        error('Invalid waveforms');
    end
    
    nChan = size(wf,1);

    d = [];
    for iChan = 1%:nChan
            w = squeeze(wf(iChan,:,:))';

            [~, s] = pca(w, 'NumComponents', 4);
            d = [d, s];
    end
    
end