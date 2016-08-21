clear;

dset = dset_load_all('Bon', 3, 2);

%%

%%
args = dset_get_standard_args;
args = args.analysis;

%% Calculate the correlation between the estimated positions during run reconstruction
tau = .25;

bilatCorrStat = {};
nRun = 101;
for i = 1:nRun
        disp(i);
        leftIdx = strcmp({dset.clusters.hemisphere}, 'left');
        
        if i>2 % shuffle leftIdx
           leftIdx = randsample(leftIdx, numel(leftIdx));
        end
     
        
        time_win = [dset.position.ts(1) dset.position.ts(end)];
        if isfield(dset,'reconRun')
            dset = rmfield(dset, 'reconRun');
        end
        
        dset.reconRun(1) = dset_reconstruct(dset.clusters(leftIdx), 'time_win', time_win, 'tau', tau, 'trajectory_type', 'individual');
        dset.reconRun(2) = dset_reconstruct(dset.clusters(~leftIdx), 'time_win', time_win, 'tau', tau, 'trajectory_type', 'individual');        
        
        trajRun = interp1(dset.position.ts, dset.position.trajectory, dset.reconRun(1).tbins, 'nearest');
        
        linvel = max(abs(dset.position.traj_linVel), [], 2);
        linvel(linvel>50) = 0;
        
        trajVel = interp1(dset.position.ts, linvel, dset.reconRun(1).tbins, 'nearest');
        
        %compute the correlations between the reconstructed estimates and
        %use the trajectory the animal was currently running 
        reconCorrelation = nan(size(dset.reconRun(1).tbins));
        sc = zeros(size(reconCorrelation));
        
        %%
        for traj = 1:4
            % get the indecies of bins for the current trajectory
            % get the indecies of bins while the animal is moving > 10
            % get the indecies of bins that have spikes in both hemispheres
            trajIdx = trajRun == traj & trajVel > 10 & sum(dset.reconRun(1).spike_counts)'>0 & sum(dset.reconRun(2).spike_counts)'>0;
            %sc = sc | (sum(dset.reconRun(1).spike_counts)'>0 & sum(dset.reconRun(2).spike_counts)'>0);           
            reconCorrelation(trajIdx) = col_corr(dset.reconRun(1).pdf{traj}(:,trajIdx), dset.reconRun(2).pdf{traj}(:,trajIdx));
            
        end
        bilatCorrStat{i} = reconCorrelation;
        
end

h = [];
p = [];
for i = 2:101
    [h(i), p(i)] = kstest2(bilatCorrStat{1}, bilatCorrStat{i});
end

sprintf('For %d runs %d were significant \n', nRun-1, sum(h));

%determine the trajectory of the animal during the reconstruction


%% Calculate the times of ripple events

%% Left vs Right Reconstruction
tau = .25;
shuffle = 1;

if shuffle==1
    nIter = 50;                                                   
else
    nIter = 1;
end

totalCorr = [];
totalCorr2 = [];


for iter = 1:nIter;
    
    for i = 1:numel(dset)

        leftIdx = strcmp({dset(i).clusters.hemisphere}, 'left');
       
        if shuffle ==1
            disp('Shuffle Left and Right laterality');
            nLeft = sum(leftIdx);
            nClust = numel(dset(i).clusters);
            leftIdx = false(1,nClust);
            leftIdx(randsample(nClust, nLeft)) = 1;
        end
        
        time_win = [dset(i).position.ts(1) dset(i).position.ts(end)];

        dset(i).reconAll(1) = dset_reconstruct(dset(i).clusters(leftIdx), 'time_win', time_win, 'tau', tau, 'trajectory_type', 'individual');
        dset(i).reconAll(2) = dset_reconstruct(dset(i).clusters(~leftIdx), 'time_win', time_win, 'tau', tau, 'trajectory_type', 'individual');

        
    %     
    %     for j = 1:size(dset(i).clusters(1).pf_edges,1)
    %         dset(i).reconPart(j,1) = dset_reconstruct(dset(i).clusters(leftIdx), 'time_win', time_win, 'tau', tau);
    %         dset(i).reconPart(j,2) = dset_reconstruct(dset(i).clusters(~leftIdx), 'time_win', time_win, 'tau', tau);
    %     end
    
    end

    % Calculate the correation of replay events between the two hemispheres
    %
    idx = [];
    events = {};
    eventCorr = {};
    eventCorrPart = {};
    corrIdx = {};

    %count the number of spikes for each time bin
    sc{1} = sum(dset.reconAll(1).spike_counts);
    sc{2} = sum(dset.reconAll(2).spike_counts);
    scIdx = (sc{1}>0 & sc{2}>0)';
    clear sc;
    
    
    for i = 1:size(dset.mu.bursts,1)
        %get the indecies for the current burst event

        idx(:) = 0;
        idxTmp(1) = find(dset.reconAll(1).tbins <= dset.mu.bursts(i,1), 1, 'last');
        idxTmp(2) = find(dset.reconAll(1).tbins >= dset.mu.bursts(i,2), 1, 'first');
        idx = false(size(dset.reconAll(1).pdf,2),1);
        idx(idxTmp(1):idxTmp(2)) = 1;
        clear idxTmp;

        %only select the bins in the current event that have spikes on both
        %sets of tetrodes
        idx = idx & scIdx;
        clear scIdx;
        
        %save the event for later use
        events{i,1} = dset.reconAll(1).pdf(:,idx);
        events{i,2} = dset.reconAll(2).pdf(:,idx);

        %get the length of the events
        %get the indecies of the current event that have spikes on both
        %channels
        corrIdx{i}= find(scIdx(idx));
        if ~isempty(corrIdx{i})
            eventCorr{i} = col_corr(events{i,1}(:,corrIdx{i}), events{i,2}(:,corrIdx{i}));
            
            pfEdges = dset(1).clusters(1).pf_edges;
            for j = 1:size(pfEdges,1)
                sptialIdx = pfEdges(j,1):pfEdges(j,2);
                c = corr(events{i,1}(sptialIdx,corrIdx{i}), events{i,2}(sptialIdx,corrIdx{i}), 'type', 'Spearman');
                
                eventCorrPart{j,i} = diag(c);%col_corr(events{i,1}(sptialIdx,corrIdx{i}), events{i,2}(sptialIdx,corrIdx{i}));
            end
    %         c = [];
    %         for j = 1:size(dset.clusters(1).pf_edges,1)
    %             c(j) = col_corr(dset.reconPart(j,1).pdf(:,idx), dset.reconPart(j,2).pdf(:,idx));
    %         end
    %         eventCorrPart{i} = max(c);
        end
    end

    for i = 1:numel(eventCorr)
        totalCorr = [totalCorr, eventCorr{i}];
        totalCorr2(end+1) = max( cellfun( @mean, eventCorrPart(:, i) ) );
    end
    disp(['Finished run: ', num2str(iter)]);
end

if shuffle==1
    tCorrShuff = totalCorr;
else
    tCorrReal = totalCorr;
end

%%
figure;
subplot(211);

bins = -1:.025:1;
hReal = histc(tCorrReal2, bins);
hReal = hReal / sum(hReal);

hShuf = histc(tCorrShuff2, bins);
hShuf = hShuf / sum(hShuf);

line(bins, smoothn(hReal, 1, 'correct', 1 ) );
line(bins, smoothn(hShuf, 1, 'correct', 1),'color','r');

subplot(212);
ecdf(tCorrReal, 'bounds', 'on', 'alpha', .05); hold on;
o = get(gca, 'Children');
ecdf(tCorrShuff, 'bounds', 'on', 'alpha', .05);
set(o, 'Color', 'r');

%%


%% Plot the reconstruction combined with the 
% figure ('Position', [ 1800 450 1500 500]);
% a = axes('Position', [.05 .55 .9 .5], 'XTick', []);
% imagesc(dset.recon(1).tbins, dset.recon(1).pbins,  [dset.recon(2).pdf],'Parent', a);
% dt = diff(dset.mu.bursts,[],2);
% for i = 1:size(dset.mu.bursts,1)    
%     my_rectangle(dset.mu.bursts(i,1), 0, dt(i), 300, '--','r', 2, gca);
% end
% a(2) = axes('position', [0.05 .2 .9 .325]);
% spike_raster_browser(dset.clusters, a(2));
% 
% a(3) = axes('Position', [.05 .05 .9 .12], 'XTick', []);
% plot(dset.mu.timestamps, dset.mu.rate,'.');
% linkaxes(a, 'x');


%% get the indecies of events that occur on both sets of channels
for i = 1:numel(dset)
    baseIdx = false(size(dset(i).ripples(1).maxTimes));
    ipsiIdx = false(size(dset(i).ripples(2).maxTimes));
    contIdx = false(size(dset(i).ripples(3).maxTimes));

    nearestIpsi = interp1(dset(i).ripples(2).maxTimes, dset(i).ripples(2).maxTimes, dset(i).ripples(1).maxTimes, 'nearest');
    ipsiIdx = abs(nearestIpsi - dset(i).ripples(1).maxTimes) <= args.ripple_dt_thold;

    nearestCont = interp1(dset(i).ripples(3).maxTimes, dset(i).ripples(3).maxTimes, dset(i).ripples(1).maxTimes, 'nearest');
    contIdx = abs(nearestCont - dset(i).ripples(1).maxTimes) <= args.ripple_dt_thold;
end

%% CA1 vs CA3 Reconstruction
for i = 1:numel(dset)
    ca1Idx = strcmp({dset(i).clusters.area}, 'CA1');
    time_win = [dset(i).position.ts(1) dset(i).position.ts(end)];
    dset(i).recon(1) = dset_reconstruct(dset(i).clusters(ca1Idx), 'time_win', time_win);
    dset(i).recon(2) = dset_reconstruct(dset(i).clusters(~ca1Idx), 'time_win', time_win);
end


%%

f = dset_plot_reconstruction(dset(1).recon, dset(1).position);

for i = 1:numel(contIdx)
   
   if contIdx(i) == 0 
       continue;
   end
   set(gca,'Xlim', [ -.25 .25] + dset(1).ripples(1).maxTimes(i));
   pause;
end
    


%%
f = figure;
a = gca;

for i = 1:1
    imagesc(dset(i).recon_run.pdf, 'parent', a);
    pause;
end

close(f);

