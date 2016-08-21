
function f = calc_inter_ripple_interval(HPC)

clearvars -except MU HPC

iriPk = [];
iriOn = [];

N = numel(HPC);
Fs = timestamp2fs(HPC(1).ts);
iri1 = [];
iri2 = [];
dur = [];
len = [];
for i = 1 : N
    
    fprintf('%d ', i);
%     mu = MultiUnit{i};
    
    [ripIdx, ripWin] = detectRipples(HPC(i).ripple, HPC(i).rippleEnv, Fs);
    [~, ~, setLen] = filter_event_sets(HPC(i).ts(ripIdx), 1, [.5 .25 .5]);
    
    fprintf(' nRipple:%d\n', nnz(ripIdx));
    
    ripPkTs = HPC(i).ts(ripIdx);
%     ripOnTs = eeg.ts(ripWin(:,1));
    iri = diff(ripPkTs);

    iriPk = [iriPk, iri];
%     iriOn = [iriOn, diff(ripOnTs)];
    d = diff(ripWin,[],2) / Fs;
    dur = [dur, (d(:))'];

    len = [len, (setLen(:))'];
    
    
end
fprintf('\n');

%%
maxT = 600;
DT = 5;
pkIri = iriPk * 1000;
pkIri = pkIri(pkIri < maxT);


bins = 0:DT:maxT;

cts = histc(pkIri, bins);

f = figure('Position', [100 260 600 300]);
subplot(211);
title('Inter Ripple Interval')
cts = cts ./ trapz(bins, cts);

bar(bins, cts, 1);

[F,X] = ksdensity(pkIri,0:1:maxT, 'Support', 'positive');
line(X,F,'Color','r', 'LineWidth', 2);

set(gca,'XLim', [0 1000]);

xlabel('Interval Length (ms)');
ylabel('Probability');

%% Distribution of ripple set lengths

subplot(223);

[cts, bins] = hist( len(len>0), 1:10);
cts = cts ./ sum(cts);
bar(bins, cts, 1);
xlabel('Set Size');
title('Ripple Set Distribution');
set(gca,'Xlim', [0, 10])

end






