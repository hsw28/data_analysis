function f = wave_time_estimates()

pTotal = [];

metadatas = {%yolanda_112511_metadata()  ...
            %,yolanda_120711_metadata()  ...
            morpheus_052310_metadata() ...
            %,caillou_112812_metadata() ...
            };
nDatasets = numel(metadatas);
histBins = linspace(-0.05,0.05,200);

for n = 1:nDatasets

    m = metadatas{n};
    baseData = [m.basePath,'/d.mat'];
    waveData = [m.basePath,'/wave_model.mat'];
    if(exist(baseData))
        load(baseData);
    else
        d = loadData(m,'segment_style','areas');
    end
    allRunBouts = [d.pos_info.out_run_bouts; d.pos_info.in_run_bouts];
    if(exist(waveData))
       load(waveData);    
       pOffset = predicted_time_offset(b,'anatomical_axis',[1,0]);
       pIsOk = gh_points_are_in_segs(b.timestamps,allRunBouts);    
       thisP = pOffset(pIsOk);
       
    else
        trode_groups = m.trode_groups_fn('date',m.today,'segment_style','areas');
        indCA1 = find(cellfun(@(x) strcmp(x.name,'CA1'),trode_groups),1,'first');
        if(isempty(indCA1))
            error('wave_time_estimates:noCA1','found no CA1 group');
        end
        eeg_r = contchans_r(d.eeg_r,'chanlabels',trode_groups{indCA1}.trodes);
        est = [];
        for i = 1:size(allRunBouts,1)
            thisTimewin = allRunBouts(i,:);
            this_eeg_r = contwin_r(eeg_r,thisTimewin + [-0.25,0.25]);
            [beta,reg_info] = gh_long_wave_regress(this_eeg_r,m.rat_conv_table);
            thisOk = gh_points_are_in_segs(beta.timestamps,allRunBouts);
            est = [est, beta.est(:,thisOk)];
            beta.timestamps = beta.timestamps(thisOk);
            beta.est = est;
        end
        pOffset = predicted_time_offset(beta,'anatomical_axis',[1,0]);
        thisP = pOffset;
    end
    
    

    pTotal = [pTotal,thisP];
    c = histc(thisP,histBins);
    plot(histBins,c,'Color',gh_colors(n)); hold on;
    modeInd = find(c == max(c),1,'first');
    thisMode = p(modeInd);
    cAtMode  = c(modeInd);
    thisMean = mean(p);
    plot(thisMode,cAtMode,'v','MarkerColor',gh_colors(n));
    
end

disp(['n: ', num2str(numel(pTotal))]);
disp(['mean: ', num2str(mean(pTotal))]);
disp(['std: ', num2str(std(pTotal))]);
disp(['ster: ', num2str( std(pTotal)/sqrt(numel(pTotal)-1))]);