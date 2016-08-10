function b = waveformHasChewArtifact( waveform,varargin )
% WAVEFORMHASCHEWARTIFACT checks waveform for chew artifact returns bool
%   True when some fraction of the samples are too close to the tallest one sample
% Input: nChan x nSamp (x nSpike) 2d (or 3d) array
% Optional: 'upperBoundFractionOfMax', 0.75      % 'danger zone' cutoff
% Optional: 'upperBoundFractionAboveMax', 0.75   %  Maximum allowed in zone before calling it chew
p = inputParser();
p.addParamValue('upperBoundFractionOfMax',   0.75);
p.addParamValue('upperBoundFractionAboveMax',0.25);
p.addParamValue('draw', false);
p.addParamValue('nExample', 4);
p.parse(varargin{:});
opt = p.Results;

nSampPerSpike = numel( waveform(:,:,1) );

% High value for each spike, expect to be size 1x1xnSpike
highVal = max(  max(waveform, [], 1), [], 2 );

inDangerZone = bsxfun(@ge, waveform, (highVal * opt.upperBoundFractionOfMax));

nInDangerZone = sum( sum(inDangerZone, 1), 2);

b = squeeze(nInDangerZone > (opt.upperBoundFractionAboveMax * nSampPerSpike));


if(opt.draw)

    subplot(opt.nExample+1, 1, 1);
    plot(b, '.');

    chewExample    = find( b,  opt.nExample, 'last');
    notChewExample = find( ~b, opt.nExample, 'last');

    for n = 1:opt.nExample

        subplot(opt.nExample+1, 2, 2*n+1);
        if(n <= numel(chewExample))
            for c = 1:4
                ind = (1:32)+(c-1)*32;
                plot( ind, waveform(c, :, chewExample(n)));
                hold on;
            end
            text(1,0,'chew: true');
        end
        subplot(opt.nExample+1, 2, 2*n+2);
        if(n <= numel(notChewExample))
            for c = 1:4
                ind = (1:32)+(c-1)*32;
                plot( ind, waveform(c, :, notChewExample(n)) );
                hold on;
            end
            text(1,0,'chew: false');
        end
    end

end