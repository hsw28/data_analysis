function f = traveling_mua(d,m,varargin)

p = inputParser();
p.addParameter('bouts',[d.pos_info.out_run_bouts;d.pos_info.in_run_bouts]);
p.addParameter('rMax',200);
p.addParameter('plotR',0.05);
p.parse(varargin{:});
opt = p.Results;

eeg = contchans(d.eeg,'chanlabels',m.singleThetaChan);
eeg_r = prep_eeg_for_regress(eeg);
if(any(isnan(eeg_r.phase.data)))
    error('traveling_mua:bad_phase','Remove NaN from phase cdat');
end
ts = conttimestamp(eeg_r.phase);
phases = unwrap(eeg_r.phase.data + pi) - pi;

phaseBins = linspace(0,2*pi,50);

for n = 1:numel(d.mua.clust)
    [x,y,c] = trodePosAndColor(d.mua.clust{n}.comp,d.trode_groups,m.rat_conv_table);
    r = plot_phases(ts, phases, ...
        d.mua.clust{n}.stimes,phaseBins,opt.bouts, x,y, opt);
end

end

function rs = plot_phases(ts,p, stimes, phaseBins, bouts, x,y, opt)

    spikePhases = interp1(ts,p,stimes(gh_points_are_in_segs(stimes,bouts)));
    spikePhases = mod(spikePhases, 2*pi);
    
    rs = histc(spikePhases,phaseBins);
    
    phaseBins = phaseBins(1:(end-1));
    phaseBins = [phaseBins(end),phaseBins];
    rs        = rs(1:(end-1)) ./ opt.rMax .* opt.plotR;
    rs        = [rs(end),rs];
    iMax      = find(rs == max(rs), 1, 'first');
    
    plot( rs .* cos(phaseBins) + x, rs .* sin(phaseBins) + y);
    hold on;
    plot( [0, rs(iMax).*cos(phaseBins(iMax))]+x, ...
          [0, rs(iMax).*sin(phaseBins(iMax))]+y);
    
end

function [x,y,c] = trodePosAndColor(tName,trode_groups,rat_conv_table)
    g = trode_group(tName,trode_groups);
    c = g.color;
    x = trode_conv(tName,'comp','brain_ml',rat_conv_table);
    y = trode_conv(tName,'comp','brain_ap',rat_conv_table);
end