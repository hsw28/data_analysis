function [f1,f2,f3,f4,eeg_r,eeg_wave] = describe_wave(d,m,varargin)

[defaultChans,defaultTWin,defaultFitTWin] = ratDefaults(m);

p = inputParser();
p.addParamValue('upleft_chanlabels',defaultChans);
p.addParamValue('timewin',defaultTWin);
p.addParamValue('fitTimewin',defaultFitTWin);
p.addParamValue('eeg_r',[]);
p.addParamValue('brainPicPath','/home/greghale/Documents/RetroProject/code/thesis/wave_fig/brainFig.png');
p.parse(varargin{:});
opt = p.Results;

if ~isfield(d,'eeg_r')
    if(isempty(opt.eeg_r))
        d.eeg_r = prep_eeg_for_regress(d.eeg,'timewin_buffer',2);
    else
        d.eeg_r = opt.eeg_r;
    end
end
eeg_r = d.eeg_r;
fields = fieldnames(d.eeg_r);
for n = 1:numel(fieldnames(d.eeg_r))
    d.eeg_r.(fields{n}).data( isnan(d.eeg_r.(fields{n}).data) ) = 0;
end

[f1] = drawBrainAndExampleWaves(d,m,opt.brainPicPath,opt.timewin,opt.upleft_chanlabels);
f2 = figure; text(0,0,'RetroProject/code/thesis/wave_fig/figure_draft');
[f3,eeg_wave] = drawTimeseries(d,m,opt.fitTimewin);

modelPath = [m.basePath,'/wave_model.mat'];
if(exist(modelPath))
    load(modelPath)
else
    error('describe_wave:not_implemented',...
        'Error, not implemented computer wave model in figure');
end

pOffset = predicted_time_offset(beta,'anatomical_axis',[1,0]);
allRunSegs = [d.pos_info.out_run_bouts; d.pos_info.in_run_bouts];
pIsOk = gh_points_are_in_segs(beta.timestamps,allRunSegs)
bins = linspace(-0.5,0.5,200)

f4 = 0;

end


function [f,eeg_r] = drawBrainAndExampleWaves(d,m,brainPicPath,tWin,chanlabels)

    figWidth  = 600;
    figHeight = 400;
    aspect = figWidth/figHeight;
    
    f = figure('Color',[1,1,1],'Position',[100,100,figWidth,figHeight]);
    subplot(1,2,1);
    image([-7.75,7.75],[9.9,-15.8], imread(brainPicPath));
    set(gca,'YDir','normal');
    hold on;
    for n = 1:numel(chanlabels)
        [x,y,c] = trodePosAndColor(chanlabels{n},d.trode_groups, d.rat_conv_table);
        plot(x,y,'.','Color',c,'MarkerSize',25);
    end
    axis equal;
    axis off;
    set(gca,'Position',[0,0,0.4,1]);
    
    eeg = contwin_r(contchans_r(d.eeg_r,'chanlabels',chanlabels),safeTimeWin(tWin,d.eeg));
    peaks = gh_troughs_from_phase(contchans_r(eeg,'chanlabels',chanlabels{1}));
    subplot(1,2,2);
    gh_plot_cont(eeg.raw,'spacing',-0.4,'colors',repmat([0.7,0.7,0.7],numel(chanlabels),1));
    hold on;
    gh_plot_cont(eeg.theta,'spacing',-0.4,'trode_groups',d.trode_groups,'LineWidth',3);
    xlim(tWin);
    [xs,ys] = gh_raster_points(peaks,'y_range',[-1.1,0.1]);
    plot(xs,ys,'k--');
    axis off;
    
    plot ([0.1,0,0]+tWin(1)+0.1,[0,0,0.1]-1.3,'k-','LineWidth',3); % Scale bar
    text(0+tWin(1)+0.1,0.05-1.3, '100uV','HorizontalAlignment','right');
    text(0.05+tWin(1)+0.1,0-1.35, '100ms','HorizontalAlignment','center');
    set(gca,'Position',[0.4,0,0.6,1]);

    eeg_r = d.eeg_r;

end

function [x,y,c] = trodePosAndColor(tName,trode_groups,rat_conv_table)
    g = trode_group(tName,trode_groups);
    c = g.color;
    x = trode_conv(tName,'comp','brain_ml',rat_conv_table);
    y = trode_conv(tName,'comp','brain_ap',rat_conv_table);
end

function tWin = safeTimeWin(tWin, cdat)
    tWin = [max(cdat.tstart,tWin(1)-2), min(cdat.tend,tWin(2)+2)];
end

function [f,eeg_wave] = drawTimeseries(d,m,timewin,timeseriesOpts)
    if (~isfield(d,'eeg_wave') || isempty(d.eeg_wave) )
        eeg_r = contwin_r(d.eeg_r,timewin);
        eeg_wave = gh_long_wave_regress(eeg_r,d.rat_conv_table);
        d.eeg_wave = eeg_wave;
    else
        eeg_wave = d.eeg_wave;
    end
    
    f = figure('Color',[1,1,1]);
    
    ax(1) = subplot(4,1,1); 
    tw = [min(d.eeg_wave.timestamps),max(d.eeg_wave.timestamps)];
    d.pos_info.lin_speed_cdat = contwin(d.pos_info.lin_speed_cdat,tw);
    shadeRunBouts(conttimestamp(d.pos_info.lin_speed_cdat),...
        d.pos_info.lin_speed_cdat.data,d,'area');
    %gh_plot_cont(d.pos_info.lin_speed_cdat,'colors',[0.7,0.7,0.7]);
    hold on;
    plot(conttimestamp(d.pos_info.lin_speed_cdat),d.pos_info.lin_speed_cdat.data,'-','Color',[0.2,0.2,0.2]);
    %set(gca,'XColor',[1,1,1]); 
    set(gca,'XTick',[]); 
    %set(gca,'YColor',[1,1,1]); 
    %set(gca,'YTick',[]);
    ylabel('Vel (m/s)');

    lambdaData = d.eeg_wave.est(2,:);
    lambdaData(lambdaData > 30) = NaN;
    d.eeg_wave.est(2,:) = lambdaData;
    ax(2) = subplot(4,1,2); shadeRunBouts(d.eeg_wave.timestamps,lambdaData,d,'area');
    set(gca,'XTick',[]);
    hold on;
    plot(d.eeg_wave.timestamps,lambdaData,'Color',[0.2,0.2,0.2]);
    ylim([0,30]);
    ylabel('{\lambda} (mm/cycle)');

    dirData = mod(d.eeg_wave.est(3,:)+pi,2*pi)-pi;
    ax(3) = subplot(4,1,3); 
    plot(d.eeg_wave.timestamps,dirData,'.','Color',[0.7,0.7,0.7]);
    set(gca,'XTick',[]);
    hold on;
    shadeRunBouts(d.eeg_wave.timestamps, dirData, d, 'points');
    ylabel('{\theta} (° from M/L)');
    linkaxes(ax,'x');

    rSqData = smooth(d.eeg_wave.r_squared,10,'moving');
    ax(4) = subplot(4,1,4); 
    shadeRunBouts(d.eeg_wave.timestamps, rSqData, d, 'area');
    xlabel('Time (sec)');
    ylabel('r^2');
    hold on;
    plot(d.eeg_wave.timestamps,rSqData);
    linkaxes(ax,'x');
    xlim(tw);

end

function shadeRunBouts(xs,ys,d,mode)
    bouts = [d.pos_info.out_run_bouts; d.pos_info.in_run_bouts];
    bouts = bouts( bouts(:,1) >= min(xs) & bouts(:,2) <= max(xs), : );
    for n = 1:size(bouts,1)
        bout = bouts(n,:);
        keep = xs>= bout(1) & xs <= bout(2);
        thisXs = xs(keep);
        thisYs = ys(keep);
        if(strcmp(mode,'area'))
            area(thisXs,thisYs,'FaceColor',[0.6,0.6,1],'LineStyle','none');
        elseif(strcmp(mode,'points'))
            plot(thisXs,thisYs,'.','Color',[0.3,0.3,1]); 
        else
            error('describe_wave:unknown_shade_mode',['No ', ...
                'implementation for shade mode ', mode]);
        end
    end
end

function [chanLabels,tWin,fitTWin] = ratDefaults(m)

     if(strContains(m.basePath,'morpheus'))
         chanLabels = {'24','17','12'};
         tWin = [904.17 904.7]; % TODO is rat running now? Kind of, not great.
         fitTWin = [885,920];
     else
         error('ratUpLeftChans:noLabelData',['Don''t know which ',...
                                             'channels to use for ',...
                                             'example wave figure']);
     end

end

function [b,twin] = strContains(a,b)
    
    b = ~isempty(regexp(a,b,'ONCE'));
       
end
