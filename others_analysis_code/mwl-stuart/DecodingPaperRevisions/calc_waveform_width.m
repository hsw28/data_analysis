function [w, highIdx, lowIdx] = calc_waveform_width(wave)

    highIdx = [];
    lowIdx = [];
   
    for i = 1:size(wave,1)

        W = squeeze( wave(i,:,:));
        
        % if only 1 waveform was detected then we need to transpose W for
        % the math to work
        if ismatrix(wave)
            W = W';
        end
            
        
        
        [~, highIdx(i,:)] = max( W(5:12,:) );
        [~, lowIdx(i,:)] = min( W(13:32,:) );

    end
            

    
    highIdx = highIdx + 4;
    lowIdx = lowIdx + 12;
    w = lowIdx - highIdx;
    
    if size( wave, 1) == 1
        w = w';
    end
    
    
end