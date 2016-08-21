clearvars -except MultiUnit LFP

win = [-.25 .25];

N = numel(MultiUnit);
Fs = timestamp2fs(LFP{1}.ts);

bins = win(1):.01:win(2);

[dtH, dtC] = deal( [] );


for i = 1 : N
    
    fprintf('%d ', i);
    mu = MultiUnit{i};
    eeg = LFP{i};
    
    [sws, ripTs] = classify_sleep(eeg.ripple, eeg.rippleEnv, eeg.ts);
    muBursts = find_mua_bursts(mu);
    cFrames = find_ctx_frames(mu);
    
    % Merge Frames within 50 ms of each other
%     muBursts = merge_frames(muBursts, .05);
%     cFrames = merge_frames(cFrames, .05);

%     % Trigger on Start of FRAME
%     hpcTrig = muBursts(:,1);
%     ctxTrig = cFrames(:,1);
%     
%     dStartHpc = bsxfun(@minus, ctxTrig, hpcTrig');
%     [~, minIdx] = min( abs( dStartHpc));
%     ind = sub2ind(size(dStartHpc), minIdx, 1:numel(hpcTrig));
%     dtHPC = [dtHPC; dStartHpc(ind(:))];
%     
%     dStartCtx = bsxfun(@minus, hpcTrig, ctxTrig');
%     [~, minIdx] = min( abs( dStartCtx));
%     ind = sub2ind(size(dStartCtx), minIdx, 1:numel(ctxTrig));
%     dtCTX = [dtCTX; dStartCtx(ind(:))];

    dStartHpc = [];

    nFrame = size(cFrames,1);
    nBurst = size(muBursts,1);
    
    
    dT = bsxfun(@minus, muBursts(:,1), cFrames(:,1)')';    
    [~, minIdx] = min( abs(dT) ); 
    minInd = sub2ind( size(dT), minIdx,  1:nBurst);
    dtH = [dtH; dT(minInd(:) )];
    
    dT = bsxfun(@minus,  cFrames(:,1), muBursts(:,1)')';    
    [~, minIdx] = min( abs(dT) ); 
    minInd = sub2ind( size(dT), minIdx,  1:nFrame);
    dtC = [dtC; dT(minInd(:) )];
   
end
fprintf('DONE!\n'); beep;


%%

c = dtC( abs(dtC) < .35 );

figure;
ax = axes('FontSize', 14);
ksdensity(c, -.3:.01:.3, 'Support', [-.35 .35]);
set(gca,'XLim', [-.3 .3]);
xlabel('Time (s)');
ylabel('Probality');
title('\DeltaTime between HPC & RSC Frame starts');


plot2svg('/data/HPC_RSC/delta_frame_start_dist.svg',gcf);