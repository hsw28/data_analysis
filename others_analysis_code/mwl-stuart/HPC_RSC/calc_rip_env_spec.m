function f = calc_rip_env_spec(MU, HPC, fld, p)
%%
% clearvars -except MU HPC fld p
N = numel(MU);
Fs = timestamp2fs(HPC(1).ts);

specHigh = [];
specLow = [];
spec = {};
rippleRate = {};
for iDay = 1 : N

    clear idx1 idx2 idx3 ripIdx startIdx setLen setId ripWin ripTs
    fprintf('%d ', iDay);
%     mu = MultiUnit{i};
    ts = HPC(iDay).ts;
    [ripIdx, ripWin] = detectRipples(HPC(iDay).ripple, HPC(iDay).rippleEnv, Fs, 'pos_struct', [], 'ts', HPC(iDay).ts);
    ripTs = ts(ripIdx);

    
    tbins = ts(1):5:ts(end);
    freqs = 1:300;
    ripRate = histc(ripTs,tbins);
    ripRate = smoothn(ripRate,1);
    ripRate(ripRate < .25) = nan;
   
    rippleRate{iDay} = ripRate;
    fprintf('Quantiles:%2.1f %2.1f', quantile(ripRate,[.25 .75]))
    
    spec{iDay} = nan(numel(tbins)-1, 513);
    
    fprintf('\n\t%d:', numel(tbins)-1)
    for iSpec = 1:numel(tbins)-1
        h = spectrum.mtm;
        if mod(iSpec,50)==0
            fprintf(' %d',iSpec);
        end
        idx = ts >= tbins(iSpec) & ts <= tbins(iSpec+1);
        p = psd(h, HPC(iDay).rippleEnv(idx),'Fs', Fs, 'NFFT', 1024);
        freqs = p.Frequencies;
        spec{iDay}(iSpec,:) = p.Data;
        
    end
    fprintf('\n')
    
    idxLow = ripRate(1:end-1) < quantile(ripRate, .25);
    idxHigh = ripRate(1:end-1) >= quantile(ripRate, .75);
    
    specLow(iDay,:) = nanmean( spec{iDay}(idxLow , :));
    specHigh(iDay,:) = nanmean( spec{iDay}(idxHigh , :));
   
end

save
%%

close all;
figure('Position', [200 600 500 250]);
plot(freqs, mean(specHigh - specLow));
line([10 10], get(gca,'YLim'));

set(gca,'XLim', [1 250]);
xlabel('Frequency(Hz)');

ylabel('HighRate / LowRate (dB)');
    

