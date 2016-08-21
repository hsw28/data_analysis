
% This analys showed a nice differential effect during run in the following
% animals:
% spl11= d11 d13 d14
%ch_ignore ={'eeg1.ch8', 'eeg2.ch5'};

epoch = 'sleep2';
ch_ignore = {'none'};
exp = exp_load('/data/spl11/day14', 'epochs', epoch, 'data_types', {'eeg', 'mu'}, 'ignore_eeg_channel', ch_ignore);
exp = process_loaded_exp(exp, 'operations', [2,8]);

ca1Ind = strcmp(exp.(epoch).eeg.loc, 'lCA1') | strcmp(exp.(epoch).eeg.loc, 'rCA1');

exp.(epoch).eeg.data = exp.(epoch).eeg.data(:,ca1Ind);
exp.(epoch).eeg.loc = exp.(epoch).eeg.loc(ca1Ind);
exp.(epoch).eeg.ch = exp.(epoch).eeg.ch(ca1Ind);
eeg = exp.(epoch).eeg;
mu = exp.(epoch).mu;
clear exp;
%%
velThold = .15;
nChan = size(eeg.loc,2);


%pos = exp.run.pos;
%isMoving = abs(pos.lv)>velThold;f
%eegMoving = interp1(pos.ts, isMoving, eeg.ts, 'nearest');
%eegMoving(isnan(eegMoving))=0;
%eegMoving=logical(eegMoving);

disp('Filtering and calculating the ripple bursts');
[ripBurst,~,~,eeg.ripple] = find_rip_burst(eeg);
eeg.ripEnvelope = abs(hilbert(eeg.ripple));
%%
m = mean(eeg.ripEnvelope);
s = std(eeg.ripEnvelope);
n_std = 3;
for i=1:size(eeg.ripple,2)
    eeg.ripBin(:,i) = eeg.ripEnvelope(:,i)>= m(i)+s(i)*n_std;
end
%%

disp('Computing PSTHs');
rippPsth = [];

nSamples = 150;
rippPsth = zeros(nChan^2, 2*nSamples+1);

for cycleCount=1:nChan^2
    i = ceil(cycleCount/nChan);
    j = mod(cycleCount,nChan)+1;
    
    
    %[p bins] = peri_stim_eeg_ave(eeg.ripEnvelope(:,i), eeg.ts, ripBurst{j}(:,1), nSamples);
    [p bins] = peri_stim_eeg_ave(eeg.ripBin(:,i), eeg.ts, ripBurst{j}(:,1), nSamples);
    %[p bins] = peri_stim_eeg_ave(eeg.ripBin(:,i), eeg.ts, mean(ripBurst{j},2), nSamples);
    rippPsth(cycleCount,:) = mean(p);
    if i==j
        rippPsth(cycleCount,:) = nan;
    end
    
  %  wb = my_waitbar(cycleCount/nChan^2, wb);
end

%%
nShuffle=0;
runCount=1;

stats =[];
eegloc = eeg.loc;
disp('Shuffling');
clear stat shuff
while runCount<=nShuffle+1
     
    if runCount>1
        eegloc = eegloc(randsample(nChan, nChan));
    end

    ll = []; labll = {};
    lr = []; lablr = {};
    rl = []; labrr = {};
    rr = []; labrl = {};

    count = 0;
    for cycleCount=1:nChan^2
        i = ceil(cycleCount/nChan);
        j = mod(cycleCount,nChan)+1;
       
        if ~(strcmp(eegloc{i}, 'lCA1') || strcmp(eegloc{i}, 'rCA1'))
            continue;
        elseif ~(strcmp(eegloc{j}, 'lCA1') || strcmp(eegloc{j}, 'rCA1'))
            continue
        end
            
        
        if strcmp(eegloc{i}, 'lCA1') % Do Left First
            if strcmp(eegloc{j}, 'lCA1') % LL
                ll(:,end+1) = rippPsth(cycleCount,:);
                labll{end+1} = num2str([i j]);
            elseif strcmp(eegloc{j}, 'rCA1') % LR
                lr(:,end+1) = rippPsth(cycleCount,:);
                lablr{end+1} = num2str([i j]);
            end
        elseif strcmp(eegloc{i}, 'rCA1') % Do Right Next
            if strcmp(eegloc{j}, 'lCA1') %RL
                rl(:,end+1) = rippPsth(cycleCount,:);
                labrl{end+1} = num2str([i j]);
            elseif strcmp(eegloc{j}, 'rCA1') % LL
                rr(:,end+1) = rippPsth(cycleCount,:);
                labrr{end+1} = num2str([i j]);
            end
        end
        if runCount==1
            llNoShuff = ll;
            rrNoShuff = rr;
            lrNoShuff = lr;
            rlNoShuff = rl;
        end

    end
    meanll = nanmean(ll,2);
    meanrr = nanmean(rr,2);
    meanlr = nanmean(lr,2);
    meanrl = nanmean(rl,2);
    
    meanIpsi = nanmean([meanll, meanrr]')';
    meanCont = nanmean([meanlr, meanrl]')';

    if runCount==1
        %%stat = meanIpsi(177)-mean(abs(mean([meanll(177) meanrr(177)])-mean([meanlr(177) meanrl(177)]));
        [~, ind] = max(meanIpsi);
        stat = meanIpsi(ind)-meanCont(ind);
    else
        [~, ind] = max(meanIpsi);
        %%shuff(runCount-1) = abs(mean([meanll(26) meanrr(26)])-mean([meanlr(26) meanrl(26)]));
        shuff(runCount-1) = meanIpsi(ind) - meanCont(ind);
        
    end
    %disp(ind);
    runCount = runCount+1;  
end
%% Peak Latencies
figure;
[~, idx] = max(ll);
plot(ll(:,idx), '.b'); hold on;

[~, idx] = max(rl);
plot(rl(:,idx), '.c');

[~, idx] = max(lr);
plot(lr(idx), '.r');

[~, idx] = max(rr);
plot(rr(idx), '.k');
%%

if nShuffle>0
    shuff = abs(shuff);
    shuffBins = linspace(min(shuff), max(shuff), 40);
    figure;
    plot([stat stat], [0 100], 'r', 'linewidth', 2); hold on;
    plot(shuffBins, smoothn(histc(shuff, shuffBins),2), 'linewidth', 2);
    p = sum(shuff>stat)/nShuffle;
    if p==0
        p = 1/nShuffle;
    end
    set(gca,'FontSize', 16, 'YTick', 0);
    title([exp.edir,  '  pValue: ', num2str(p)]);
    set(gca,'YLim',[1 max(histc(shuff, shuffBins))]);
    ylabel('Relative Frequency');
    legend({'Observed Difference', 'Shuffle Distribution'}, 'location', 'northwest');
end

%%
figure;
subplot(221); imagesc(bins, 1:size(ll,2),llNoShuff');
set(gca,'ytick', 1:size(llNoShuff,2), 'yticklabel', {}, 'fontsize', 16);title('LxL'); 
subplot(222); imagesc(bins, 1:size(lr,2),lrNoShuff'); 
set(gca,'ytick', 1:size(lrNoShuff,2), 'yticklabel', {}, 'fontsize', 16);title('LxR');
subplot(223); imagesc(bins, 1:size(rr,2),rr');
set(gca,'ytick', 1:size(rrNoShuff,2), 'yticklabel', {}, 'fontsize', 16);title('RxR'); 
subplot(224); imagesc(bins, 1:size(rl,2),rl');
set(gca,'ytick', 1:size(rlNoShuff,2), 'yticklabel', {}, 'fontsize', 16);title('RxL'); 

%%
figure();
plot(bins/750, smoothn(meanIpsi,1), 'r', 'linewidth', 2,'LineSmoothing', 'on'); hold on;
plot(bins/750, smoothn(meanCont,1), 'g', 'linewidth', 2);
set(gca,'FontSize', 16, 'color', 'k');
xlabel('Time (s)');
if nShuffle>1
    l = legend({'Ipsi - Shuffled', ' Contra - Shuffled'}, 'location', 'northwest');
else
    l = legend({'Ipsilateral', 'Contralateral'},  'location', 'northwest');
end
set(l,'TextColor', 'w');
title(exp.edir);
%% - no color
figure();
plot(bins/750, smoothn(meanIpsi,1), 'r', 'linewidth', 2,'LineSmoothing', 'on'); hold on;
%plot(bins/750, smoothn(meanCont,1), 'g', 'linewidth', 2);
set(gca,'FontSize', 16, 'Xtick', -.2:.05:.2);
grid on;
xlabel('Time (s)');

title(exp.edir);


%%
figure();
plot(bins/750, smoothn(meanIpsi,1), 'r', 'linewidth', 2,'LineSmoothing', 'on'); hold on;
plot(bins/750, smoothn(meanCont,1), 'g', 'linewidth', 2);
set(gca,'FontSize', 16, 'color', 'k');
xlabel('Time (s)');
if nShuffle>1
    l = legend({'Ipsi - Shuffled', ' Contra - Shuffled'}, 'location', 'northwest');
else
    l = legend({'Ipsilateral', 'Contralateral'},  'location', 'northwest');
end
set(l,'TextColor', 'w');
title(exp.edir);


%%
figure();
plot(bins/750, smoothn(meanll,3), 'r', 'linewidth', 2,'LineSmoothing', 'on'); hold on;
plot(bins/750, smoothn(meanlr,3), 'g', 'linewidth', 2);
plot(bins/750, smoothn(meanrl,3), 'c', 'linewidth', 2,'LineSmoothing', 'on'); hold on;
plot(bins/750, smoothn(meanrr,3), 'y', 'linewidth', 2);
set(gca,'FontSize', 16, 'color', 'k');
xlabel('Time (s)');
l = legend({'LxL', 'LxR', 'RxL', 'RxR'},  'location', 'northwest');
set(l,'TextColor', 'w');
title(exp.edir);

%%
co = zeros(size(eeg.data,2));
for i=1:size(eeg.data,2)
    for j=1:size(eeg.data,2)
        if i==j
            co(i,j) = nan;
        else
            co(i,j) = corr(eeg.ripBin(:,i), eeg.ripBin(:,j));        
        end
    end
end


%%
nShuffle=0;
runCount=1;

stats =[];
eegloc = eeg.loc;
disp('Shuffling');
clear stat shuff
cshuff = [];
while runCount<=nShuffle+1
     
    if runCount>1
        eegloc = eegloc(randsample(nChan, nChan));
    end

    cll = []; labll = {};
    clr = []; lablr = {};
    crl = []; labrr = {};
    crr = []; labrl = {};

    count = 0;
    for cycleCount=1:nChan^2
        i = ceil(cycleCount/nChan);
        j = mod(cycleCount,nChan)+1;
        if j==i
            continue
        end
        if ~(strcmp(eegloc{i}, 'lCA1') || strcmp(eegloc{i}, 'rCA1'))
            continue;
        elseif ~(strcmp(eegloc{j}, 'lCA1') || strcmp(eegloc{j}, 'rCA1'))
            continue
        end
            
        if strcmp(eegloc{i}, 'lCA1') % Do Left First
            if strcmp(eegloc{j}, 'lCA1') % LL
                cll(:,end+1) = co(i,j);
            elseif strcmp(eegloc{j}, 'rCA1') % LR
                clr(:,end+1) = co(i,j);
            end
        elseif strcmp(eegloc{i}, 'rCA1') % Do Right Next
            if strcmp(eegloc{j}, 'lCA1') %RL
                crl(:,end+1) = co(i,j);
            elseif strcmp(eegloc{j}, 'rCA1') % LL
                crr(:,end+1) = co(i,j);
            end
        end
        if runCount==1
            cllNoShuff = cll;
            crrNoShuff = crr;
            clrNoShuff = clr;
            crlNoShuff = crl;
        end

    end
    meancll = mean(cll,2);
    meancrr = mean(crr,2);
    meanclr = mean(clr,2);
    meancrl = mean(crl,2);
    
    CIpsi = [cll(:); crr(:)];
    CCont = [clr(:); crl(:)];
    meanCIpsi = mean(CIpsi')';
    meanCCont = mean(CCont')';

    if runCount==1
        [~ ind] = max(meanIpsi);
        %%stat = meanIpsi(177)-mean(abs(mean([meanll(177) meanrr(177)])-mean([meanlr(177) meanrl(177)]));
        stat = meanCIpsi-meanCCont;
    else
        %%shuff(runCount-1) = abs(mean([meanll(26) meanrr(26)])-mean([meanlr(26) meanrl(26)]));
        cshuff(runCount-1) = abs(meanCIpsi-meanCCont);
    end
    
    runCount = runCount+1;  
end
%%
if nShuffle>0
    shuffBins = linspace(min(cshuff), max(cshuff), 40);
    figure;
    plot([stat stat], [0 100], 'r', 'linewidth', 2); hold on;
    plot(shuffBins, smoothn(histc(cshuff, shuffBins),2), 'linewidth', 2);
    p = sum(cshuff>stat)/nShuffle;
    if p==0
        p = 1/nShuffle;
    end
    set(gca,'FontSize', 16, 'YTick', 0);
    title([exp.edir,  '  pValue: ', num2str(p)]);
    set(gca,'YLim',[1 max(histc(cshuff, shuffBins))]);
end
%%
figure; imagesc(co);
%% - without color
figure;
plot(CIpsi, '.r', 'linewidth', 2); hold on;
%plot(CCont, '.g', 'linewidth', 2);
set(gca,'FontSize', 16);
grid on;
xlabel('Time (s)');
if nShuffle>1
    l = legend({'Ipsi - Shuffled', ' Contra - Shuffled'}, 'location', 'northeast');
else
    l = legend({'Ipsilateral', 'Contralateral'},  'location', 'northeast');
end
set(l,'TextColor', 'w');
title(exp.edir);
%%
figure;
plot(cll, '.r', 'linewidth', 2); hold on;
plot(crr, '.y', 'linewidth', 2);
plot(crl, '.g', 'linewidth', 2);
plot(clr, '.c', 'linewidth', 2);
set(gca,'FontSize', 16, 'color', 'k');
xlabel('Time (s)');
if nShuffle>1
    l = legend({'LxL', 'RxR', 'RxL', 'LxR'}, 'location', 'northeast');
else
    l = legend({'LxL', 'RxR', 'RxL', 'LxR'}, 'location', 'northeast');
end
set(l,'TextColor', 'w');
title(exp.edir);
