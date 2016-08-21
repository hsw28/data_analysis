function d = calc_waveform_princom(wf, nChan)

    if ndims(wf) ~= 3
        error('wf must be MxNxP');
    end
    
    if size(wf,3) == 0
        d = [];
        return;
    end
    
    if ~isscalar(nChan) || ~isnumeric(nChan) || ~inrange(nChan, [1 4])
        error('nChan must be a numeric scalar between 1 and 4');
    end
    
    nPC = 3; % compute 3 principle components per waveform channel
    
    d = nan( size(wf,3), nChan * nPC );
    colIdx = 1:3;

    for iChan = 1:nChan
        
            wSingleChan = squeeze(wf(iChan,:,:))';

            [~, s] = pca( wSingleChan , 'NumComponents', nPC);
            d( :, colIdx ) = s; 
            
            colIdx = colIdx + 3;
            
    end

end
