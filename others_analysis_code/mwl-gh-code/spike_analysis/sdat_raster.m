function sdat_raster(sdat,varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('eeg',[]);
p.addParamValue('format','b');
p.addParamValue('scale_y',1);
p.addParamValue('rate_cdat',[]);
p.addParamValue('rate_y_range',[]);
p.addParamValue('trode_groups',[]);
p.addParamValue('draw_x_ticks',true);
p.addParamValue('draw_y_ticks',false);
p.addParamValue('draw_labels',false);
p.parse(varargin{:});
opt = p.Results;

timewin = opt.timewin;

if(isempty(timewin))
    starts = zeros(1,numel(sdat.clust));
    ends = zeros(1,numel(sdat.clust));
    for n = 1:numel(sdat.clust)
        starts(n) = min(sdat.clust{n}.stimes);
        ends(n) = max(sdat.clust{n}.stimes);
    end
    timewin = [min(starts), max(ends)];
end

nclust = numel(sdat.clust);

if(~isempty(opt.timewin))
    sdat = sdatslice(sdat,'timewin',timewin);
end
    
for i = 1:nclust
    if(~isempty(opt.trode_groups))
        this_color = trode_color(sdat.clust{i}.comp, opt.trode_groups);
    else
        this_color = [0 0 1];
    end
    nspike = numel(sdat.clust{i}.stimes);
    spikes = sdat.clust{i}.stimes';
    
    xs = NaN.*zeros(1,nspike*3);
    ys = NaN.*zeros(1,nspike*3);
    
    tic_bottom = i-0.5;
    tic_top = i+0.5;
    
    ind1 = ([1:nspike]-1) .* 3 + 1;
    ind2 = ([1:nspike]-1) .* 3 + 2;
    
    size(ind1);
    size(spikes);
    
    xs(ind1) = spikes;
    xs(ind2) = spikes;
    ys(ind1) = tic_bottom;
    ys(ind2) = tic_top;
    
    plot(xs,ys.*opt.scale_y,opt.format,'Color',this_color);
    hold on
    if(opt.draw_labels)
        text(xs(1), mean(ys(1:2)), sdat.clust{i}.comp);
    end
end

if(~opt.draw_x_ticks)
    set(gca,'XTickLabel',cell(0));
end
if(~opt.draw_y_ticks)
    set(gca,'YTickLabel',cell(0));
end

if(~isempty(opt.eeg))
    if(~isempty(opt.timewin))
        opt.eeg = contwin(opt.eeg, opt.timewin);
    end
    
    n_chans = size(opt.eeg.data,2);
    ts = conttimestamp(opt.eeg);
    for i = 1:n_chans
        this_data = opt.eeg.data(:,i) ./ max(opt.eeg.data(:,i));
        plot(ts, this_data + i + nclust);
        
    end
        
end

if(~isempty(opt.rate_cdat))
    ts = conttimestamp(opt.rate_cdat);
    data = sum(opt.rate_cdat.data,2)' ./ size(opt.rate_cdat,2);
    if(~isempty(opt.rate_y_range))
        data = (data / (max(data) - min(data)) - min(data)) * diff(opt.rate_y_range) + opt.rate_y_range(1);
    end
    plot( ts, data );
end