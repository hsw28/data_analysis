function [swsSeg, ripTs] = classify_sleep(ripBand, ripEnv, T, varargin)


[pkIdx] = detectRipples(ripBand, ripEnv, timestamp2fs(T) );
ripTs = T(pkIdx);

bins = T(1):5:T(end);
rate = histc(ripTs, bins);


rate = smoothn(rate, 5, 'correct', 1);
thold = 1.5;

swsSeg = logical2seg(bins, rate >= thold);
% 
% figure;
%  plot(bins, rate); hold on;
%  plot(bins, rate >= thold);

end



% if ~isa(X, 'double')
%     X = double(X);
% end
% %%
% Fs = 1500;
% 
% args.win_len = 1;
% args.TimeBW = 6;
% 
% args.frDelta = [1 4];
% args.frTheta = [5 10];
% args.frRipple = [125 250];
% 
% mtm = spectrum.mtm(args.TimeBW);
% 
% maxT = floor(T(end));
% curT = T(1);
% 
% idx = 1:Fs;
% 
% nSamp = numel(X);
% nIter = floor( T(end) - T(1) ) - 1;
% fprintf('NIter:%d\n', nIter);
% % nIter = 100;
% 
% NFFT = 2048;
% nSpec = NFFT/2 + 1;
% 
% spec = nan(nIter, nSpec);
% 
% for i = 1:nIter
% 
%     if mod(i, 25) == 0
%         fprintf('%d of %d\n', i, nIter);
%     end
%     
%     idx = (1:Fs) + (i-1)*Fs;
%     h = psd(mtm, X(idx), 'Fs', Fs, 'NFFT', NFFT);
%     spec(i,:) = h.Data;
%        
% end
% 
% 
% TS = T(1):T(1)+nIter-1;
% fr = linspace(0, Fs/2, nSpec);
% 
% idxDelta = fr >= args.frDelta(1) & fr <= args.frDelta(2);
% idxTheta = fr >= args.frTheta(1) & fr <= args.frTheta(2);
% idxRipple = fr >= args.frRipple(1) & fr <= args.frRipple(2);
% 
% dPow = mean( spec(:, idxDelta), 2);
% tPow = mean( spec(:, idxTheta), 2);
% rPow = mean( spec(:, idxRipple), 2);
% 
% plot( mean( log( spec ) ) );
% set(gca,'XLim', [0 300]);
% 
% 
% %%
% Fs = timestamp2fs( eeg.ts );
% X = eeg.data;
% T = eeg.ts;
% 
% 
% dFilt = getfilter(Fs, 'slow', 'win');
% tFilt = getfilter(Fs, 'theta', 'win');
% 
% d = filtfilt(dFilt, 1, X);
% t = filtfilt(tFilt, 1, X);
% % 
% % d = d.^2;
% % t = t.^2;
% % r = r.^2;
% 
% d = abs(hilbert(d));
% t = abs(hilbert(t));
% 
% ts = downsample(T, 30);
% d = downsample(d, 30);
% t = downsample(t, 30);
% %%
% dSm = smoothn(d, 50,1, 'kernel', 'box', 'normalize', 0);
% tSm = smoothn(t, 50,1, 'kernel', 'box', 'normalize', 0);
% tdRatio =  tSm./dSm;
% close all;
% figure;
% subplot(211);
% plot(ts, tdRatio);
% 
% subplot(212);
% tbins = ts(1):5:ts(end);
% ripRate = hist(eeg.ts(ripPk),tbins);
% ripRate = smoothn(ripRate, 2,'correct', 0);
% plot(tbins, ripRate);
% 
% linkaxes( get(gcf,'Children'), 'x');



%%

% 
% figure;
% 
% % ax(1) = subplot(211);
% % plot(TS, tPow ./ dPow);
% % 
% % ax(2) = subplot(212);
% plot(tsD, smoothn( smoothn(tD, 10, 'correct', 1) ./ smoothn(dD, 10, 'correct', 1), 150, 'correct', 1) );
% 
% linkaxes(ax,'x');

%%


% 
% rFilt = getfilter(fs, 'ripple', 'win');
% tFilt = getfilter(fs, 'theta', 'win');
% dFilt = getfilter(fs, 'slow', 'win');
% 
% r = filtfilt(rFilt, 1, eeg);
% t = filtfilt(tFilt, 1, eeg);
% d = filtfilt(dFilt, 1, eeg);

%%


