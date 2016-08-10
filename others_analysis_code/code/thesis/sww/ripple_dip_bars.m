function f = ripple_dip_bars()

% horizontal bar for the duration of run with arrows at dip times and
% ripple times
% Want examples of: Regular running on track, large rewards
%                   Late-night non-sleepy
%                   Early running, dips for small rewards
%                   Late running, dips for big and unsurprising rewards

% 112812 is the standard day
% 120912 is nighttime track!
% 112412 is early run, ripples for small rewards
% Skipping 121712 b/c position seems wacked out. (looking again. What's the
%                                                 prob? - Feb 08 2015)

metadatas = {caillou_112812_metadata() ,...
             caillou_120912_metadata() ,...
             caillou_112412_metadata() } %,...
             %caillou_121712_metadata() } % import problems?
            % };

% metadatas = {blue_040513_metadata()};  % This was a quick test
            
for n = 1:numel(metadatas)
    
    drawAll = false;
    m = metadatas{n};
    dataPath = [m.basePath,'/d.mat'];
    if(exist(dataPath))
        load(dataPath);
    else
        cd(m.basePath);
        d = loadData(m.basePath,'segment_style','areas');
        save(dataPath,'d');
    end
    d.trode_groups = m.trode_groups_fn('date',m.today,'segment_style','areas');

    tMin = 0;
    %pos_ts = conttimestamp(d.pos_info.lin_vel_cdat);
    %y0 = n*0.5;
    %tMin = min(pos_ts);
    %pos_ts = pos_ts - tMin;
    %pos_v  = d.pos_info.lin_vel_cdat.data;
    %pos_v = smooth(pos_v,100) ./ 3;

    
    [dips,~] = find_dips_frames(d.mua_rate,'trode_groups',d.trode_groups);
    dips = cmap(@(x) x - tMin,dips);
    
    muaRateHpc = contchans_trode_group(d.mua_rate,d.trode_groups,'CA1');
    muaRateHpc.data = mean(muaRateHpc.data,2);
    muaRateHpc.chanlabels = {'mean'};
    muaRateHpc.data = smooth(muaRateHpc.data,50);
    [~,ripplePeakTimes] = eegRipples(muaRateHpc,100,50,0.020,0.01,60,0.01);
    [~,~,rEnv] = gh_ripple_filt(contchans_trode_group(d.eeg,d.trode_groups,'CA1'));
    rEnv.data = mean(rEnv.data,2);
    rEnv.chanlabels = {'meanRippleEnv'};
    rEnv.data = smooth(rEnv.data,100);
    rippleEnvThresh = 0.0325;
    passesThresh = ...
        interp1(conttimestamp(rEnv),rEnv.data,ripplePeakTimes) >= ...
        rippleEnvThresh;
    ripplePeakTimes = ripplePeakTimes(passesThresh);
    
    %plot([0,max(pos_ts)],[y0,y0]);
    hold on;
    %plot(pos_ts,pos_v+y0);
    cellfun(@(x) plot([mean(x),mean(x)],[y0+0.1, y0+0.2],'g-','Color',[0,0.5,0]),dips);
    for r = 1:numel(ripplePeakTimes);
        plot([ripplePeakTimes(r),ripplePeakTimes(r)] - tMin,...
             [y0-0.2,y0-0.1],'b-');
    end
    if(drawAll)
        plot(conttimestamp(rEnv)-tMin,rEnv.data'.*(-20) + y0 -0.3,'b');
        plot(conttimestamp(rEnv)-tMin,(y0-0.3).*ones(size(conttimestamp(rEnv))),'b');
        plot(conttimestamp(muaRateHpc)-tMin,muaRateHpc.data'./(200) + y0 + 0.2,'g');
        plot(conttimestamp(muaRateHpc)-tMin,(y0+0.2).*ones(size(conttimestamp(muaRateHpc))),'g');
    end
    
end
    
    