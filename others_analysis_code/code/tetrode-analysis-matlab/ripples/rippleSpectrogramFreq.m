function freqCdat = rippleSpectrogramFreq(eegRipple,varargin)
% freqCdat = rippleSpectrogramFreq(eegRipple,['winLength',0.01],['winSlide',0.005]);
    
    p = inputParser();
    p.addParamValue('winLength',0.05);
    p.addParamValue('winSlide', 0.025);
    p.addParamValue('method', 'spectrogramMean');
    p.parse(varargin{:});
    opt = p.Results;

    nChan = size(eegRipple.data,2);
    
    freqCdat = eegRipple;  % Copy to preallocate space
    freqTs = conttimestamp(freqCdat);
    
    for n = 1:nChan
        [t,f] = lfunPeakFreq(contchans(eegRipple,'chans',n),opt);
        thisFreq = interp1(t,f,freqTs);
        freqCdat.data(:,n) = thisFreq';
    end
    
end

function [t,pFreq] = lfunPeakFreq(cdatOneChan,opt)

    cdatOneChan.chanlabels
    tWin   = [opt.winLength, opt.winSlide];
    params.Fs = cdatOneChan.samplerate;
    [S,t,f] = mtspecgramc(reshape(cdatOneChan.data,1,[]),tWin,params);

    if(strcmp(opt.method,'spectrogramMean'))
        fSum = sum(S,2);
        pFreq = bsxfun(@times, S, f);
        pFreq = sum(pFreq,2) ./ fSum;
        pFreq = pFreq';
    elseif(strcmp(opt.method,'spectrogramMode'))
        error('rippleSpectrogramFreq:unimplementedMode','unimplemented');
        fMax  = max(S,2);
        freq  = repmat(f,size(S,2),1);
        %        pFreq = 
    end
    
    % imagesc(t,f,log(S')); hold on;
    % ind = fSum >= 0.00005; plot(t(ind'),pFreq(ind'),'.')
end