% For ripple detection code see fig1_sandbox.m
clear;

ripples = dset_load_ripples;

clear rPhase rFreq cPhase cFreq aPhase aFreq
[rPhase.S, cPhase.S, aPhase.S] = calc_bilateral_ripple_phase_diff(ripples.sleep);
[rFreq.S,  cFreq.S, aFreq.S] = calc_bilateral_ripple_freq_distribution(ripples.sleep);

[rPhase.R, cPhase.R, aPhase.R] = calc_bilateral_ripple_phase_diff(ripples.run);
[rFreq.R, cFreq.R, aFreq.S] = calc_bilateral_ripple_freq_distribution(ripples.run);

%%

fBins = 150:1:225;

img{1} = ksdensity2([rFreq.S.trig, rFreq.S.ipsi], fBins, fBins);
img{2} = ksdensity2([rFreq.R.trig, rFreq.R.ipsi], fBins, fBins);

img{3} = ksdensity2([rFreq.S.trig, rFreq.S.cont], fBins, fBins);
img{4} = ksdensity2([rFreq.R.trig, rFreq.R.cont], fBins, fBins);

%%
close all;
figure('Position', [300 540 565 560]);
fprintf('\n\n');
for i = 1:4
    subplot(2,2,i);

    thold = quantile(img{i}(:), .5);
    c = contourc(fBins, fBins, img{i}, [0 0] + thold); hold on;
    
    result = parse_contour_matrix( c );
    c = result(1);
    
    
    [e.Z, e.A, e.B, e.ALPHA] = fitellipse( [c.x; c.y] );
    [el.x, el.y] = ellipse_points( e.Z, e.A, e.B, e.ALPHA );
    p = patch(el.x, el.y, [.5 1 1]);
    
    
    if e.ALPHA < 0
        e.ALPHA = e.ALPHA * -1;
        [e.A, e.B] = deal(e.B, e.A);
    end
    fprintf('A:%2.2f B:%2.2f Alpha:%2.2f\n', e.A, e.B, e.ALPHA);
    
    
    title( sprintf('%2.2f',  e.B/e.A));
    set(gca,'Xlim', [150 225], 'YLim', [150 225]);

    
end


%%

close all;

figure('Position', [300 540 265 560]);
subplot(211);
imagesc(fBins, fBins, fIS);
title('Ipsi Sleep');

subplot(212);
imagesc(fBins, fBins, fIR);
title('Ipsi Run');

set( get(gcf,'Children'), 'YDir', 'normal');


figure('Position', [600 540 265 560]);
subplot(211);
imagesc(fBins, fBins, fCS);
title('Contra Sleep');

subplot(212);
imagesc(fBins, fBins, fCR);
title('Contra Run');

set( get(gcf,'Children'), 'YDir', 'normal');
