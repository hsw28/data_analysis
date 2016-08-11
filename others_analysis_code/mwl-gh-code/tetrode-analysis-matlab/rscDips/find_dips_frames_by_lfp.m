function [dips,frames] = find_dips_frames_by_lfp(filteredEeg,thresh,varargin)

    p = inputParser();
    p.addParamValue('draw',false);
    p.parse(varargin{:});
    
    filteredEeg = contmap(@(x) mean(x,2), filteredEeg);
    
    devNSmooth = floor(0.1 * filteredEeg.samplerate);
    baseNSmooth = floor(2 * filteredEeg.samplerate); % Two-second rolling baseline

    deviation = contmap(@(x) smooth(x,devNSmooth) - smooth(x,baseNSmooth),...
        filteredEeg);
    %deviation = filteredEeg;
    
    dip_crit = seg_criterion('cutoff_value', thresh,...
        'threshold_is_positive',false,...
        'bridge_max_gap',0.005,'min_width_pre_bridge',...
        0.01,'min_width_post_bridge',0.03);
    
    dips = gh_signal_to_segs(deviation,dip_crit);
    
    frames = gh_invert_segs(dips);
    frames = filterCell(@(x) diff(x) < 2, frames);

    if(p.Results.draw)
        gh_plot_cont(filteredEeg);
        hold on;
        %gh_plot_cont( contZipWith(@(x,y) x-y, filteredEeg, deviation));
        gh_draw_segs({frames,dips},'names',{'frames','dips'},'ys',{[-0.04,-0.03],[-0.03,-0.02]});
    end
        
end