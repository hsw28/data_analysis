function f = reconstruction_fig()

[xs,steps] = collect_reconstruction_xcorr();

% Get reconstruction example
m = caillou_112812_metadata(); % Don't change this anymore!
exampleTimewin = [5724,5724.75];
% Alternative click_points adjust the seam in the circular track
m.linearize_opts.click_points = ...
    [243.0061  247.6463  251.4795  255.5145  256.7249  258.5407  257.9354  255.1110  252.0847  247.8480  243.0061  238.1641  233.1204  226.2609  220.6120  212.9455  206.4896  200.6389  195.1917  188.1305  180.4640  171.7888  162.9119  152.8245  143.5440  133.2549  125.3867  117.9220  110.8608  104.6066  97.3436   90.6859   84.0282   76.9670   73.3356   69.9059   69.9059   71.7216   76.1601   82.0108   87.8615   93.3087   99.5629  108.4398  115.5010 123.7727  133.8601  141.9301  149.5965  158.8769  166.3416  175.2186  183.0868  191.5602  199.4284  208.1036  216.5770  222.4277  227.8749  233.3221  238.7693  242.4008;...
     80.5585   86.4662   95.5961  106.8743  116.0043  133.7272  147.6907  160.0430  168.6359  177.7658  186.8958  193.3405  200.8593  206.2299  209.9893    214.8228  218.5822  220.1933  222.8786  226.1010  226.1010  226.6380  229.8604  228.7863  226.6380  223.9527  222.3416  218.5822  211.0634  205.1557  199.2481  193.3405  184.2105  171.3212  156.8206  141.2460  124.0602  111.7078   97.2073   86.4662   75.7250   69.2803   61.7615   55.8539   49.4092 43.5016   39.7422   38.1310   34.9087   35.4458   35.4458   37.5940   38.6681   41.3534   43.5016   46.1869   52.0945   54.7798   59.0763   64.9839   73.0397   78.4103]';      

dataPath   = [m.basePath,'/rposExampleData.mat']; % base data
rposXCPath = [m.basePath,'/rposData.mat'];        % big rpos xcorr data
expPath    = [m.basePath,'/expData.mat'];         % re: reconstruction data

if(exist(rposXCPath))
    load(rposXCPath)
else
    error('reconstruction_fig:no_xcorr_data','Need today''s big rpos xcorr data.');
end
if(~exist(dataPath))
    d = loadData(m,'segment_style','ml');
    save(dataPath,'d');
else
    load(dataPath);
    d.trode_groups = m.trode_groups_fn('date',m.today,'segment_style','ml');
end
if(exist(expPath))
    load(expPath)
else    
    d.trode_groups = ...
        d.trode_groups( cellfun(@(x) any(strcmp(x.name,{'medial','lateral'})), ...
        d.trode_groups) );
    d.trode_groups{1}.color = [1,0,0];
    d.trode_groups{2}.color = [0,1,0];

    rpos = decode_pos_with_trode_pos(d.spikes,d.pos_info,...
        d.trode_groups,'r_tau',0.020,'field_direction','outbound');

    [rpTrig,trigTimesOut] = gh_triggered_reconstruction(rpos,...
        d.pos_info,'lfp',d.thetaRaw,'min_vel',0.2);
    save(expPath,'rpos','rpTrig','trigTimesOut');
end

rposTs        = linspace(rpos(1).tstart,rpos(1).tend,...
    size(rpos(1).pdf_by_t,2));
tsInWin       = gh_points_are_in_segs(rposTs,{exampleTimewin});
rposTs        = rposTs(tsInWin);
for n = 1:numel(rpos)
    rpos(n).pdf_by_t = rpos(n).pdf_by_t(:,tsInWin);
    rpos(n).ts = rposTs;
    rpos(n).tstart = min(rposTs);
    rpos(n).tend   = max(rposTs);
end

rpTrig(1).pdf_by_t = rpTrig(1).pdf_by_t .^2;  % Enhance color diff
rpTrig(2).pdf_by_t = rpTrig(2).pdf_by_t .^2;

subplot(1,2,1);

d.spikes = sdatslice(d.spikes,'timewin',exampleTimewin);

plot_rpos_and_fe_raster(rpos,d.spikes,d.pos_info,...
    'trode_groups',d.trode_groups,'split_plots',false,...
    'color_by_group',true);
ylim([0,2.5]);
xlim(exampleTimewin);
hold on;
eegExample = contwin(contchans(d.eeg_r.theta,'chanlabels',m.singleThetaChan),...
    exampleTimewin);

lfpY = eegExample.data * 5 + 0.75;
plot(conttimestamp(eegExample),lfpY);

boxH = 0.75;
boxW = 0.10;

tt = gh_points_in_segs(trigTimesOut,{exampleTimewin});
for i = 1:numel(tt)
    thisX = tt(i);
    thisY0 = interp1(conttimestamp(eegExample),lfpY,tt(i));
    thisY1 = interp1(conttimestamp(d.pos_info.lin_cdat),...
        d.pos_info.lin_cdat.data,tt(i)) - boxH/2;
    plot([thisX,thisX],[thisY0,thisY1]);
    plot(thisX+[-boxW/2,boxW/2],thisY1*[1,1],'w');
    plot(thisX+[-boxW/2,boxW/2],(thisY1+boxH)*[1,1],'w');
    %rectangle('Position',[thisX-boxW/2, thisY1, boxW, boxH]);
end

subplot(2,4,3);
plot_multi_r_pos(rpTrig(1), d.pos_info, 'norm_c',true,'e',1);
subplot(2,4,4);
plot_multi_r_pos(rpTrig(2), d.pos_info, 'norm_c',true,'e',1);

subplot(2,2,4);
% Todo: fix magic 6's.
dx = mean(diff(d.spikes.clust{1}.field.bin_centers));
imagesc([min(steps),max(steps)],dx.*[-6,6],rs); 
set(gca,'YDir','normal');
hold on;
plot([0,0],[-0.1,0.1],'w');
plot([-0.02,0.02],[0,0],'w');
