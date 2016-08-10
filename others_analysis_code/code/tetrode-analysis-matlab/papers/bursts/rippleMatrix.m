function fs = rippleMatrix()

rats = burstsRats();
ratNames = rats.keys();


cName   =  {'rippleRate','arityPtc', 'rippleAmp','rippleFreq',...
            'burstFirstAmp','burstSndAmp','burstThirdAmp',...
            'dipTriggeredHpcLFP','dipTriggeredHpcMUA',...
            'dipTriggeredHpcLFPBreakdown','dipTriggeredHpcMUABreakdown',...
            'dipTriggeredRipple',...
            'dipTriggeredRscLFPBreakdown','dipTriggeredRscMUABreakdown',...
            'dipTriggeredRscLFP','dipTriggeredRscMUA'};
nC = numel(cName);
fs = cell(1,nC);

for ratI = 1:numel(ratNames)
    ratName = ratNames{ratI};
    allDays = rats(ratName);
    for dayI = 1:numel(allDays)
        dayName = allDays{dayI};
        dirName = ['/home/greghale/Data/',ratName,'/',dayName];
        p = pwd;
        cd(dirName);
        m = metadata();
        e = loadMwlEpoch('filename',[dirName,'/epoch.epoch']);
        loadTimewin = [min(e('sleep1')),max(e('sleep2'))];
        d = loadData(m,'timewin',loadTimewin,'samplerate',610,'loadMUA',false);
        states = behavioralState(d.pos_info,m.pFileName,eegByArea(d.eeg,m.trode_groups,'CA1'));
        cd(p);
        for c = 1:nC
            fs{c} = lfun_result(fs{c}, cName{c},m,states,d);
        end

    end
end

end

function f = lfun_result(f0, experName, m, states, d)
experStates = {'running','rem','sws'}; % These names come from behavioralState.m
                                       % change behavioralState.m to include
                                       % SWWLight, SWWDeep, SWSLight, SWSDeep
experColors = {[1,0,0],[0,1,0],[0,0,1]};
f = cell(1,numel(experStates));

if(strcmp(experName,'rippleRate'))
    [rippleEeg,~,rippleEnv] = gh_ripple_filt(eegByArea(d.eeg,m.trode_groups,'CA1'));
    envMean = rippleEnv;
    envMean.data = mean(envMean.data,2);
    eMean = mean(envMean.data);
    eStd  = std(envMean.data);
    [ripples,peakTimes] = eegRipples(envMean, eMean+5*eStd, eMean+1*eStd, 0.03, 0.005, eMean+3*eStd,0.01);
    for twI = 1:numel(experStates)
        tw = states(tw);
        nRipples = sum(gh_points_are_in_segs(peakTimes,tw));
        f{twI} = [f0{twI}, nRipples];
    end


else
 f = 0;
end


end