function pObj = patch_browser(dat, ts, varargin)

[a args]= axescheck(varargin{:});

if isempty(a)
    f = figure();
    a = axes();
end

data = dat;
timestamps = ts;


xlim_listener = addlistener(a, 'XLim', 'PostSet', @(src,e) refresh);
pObj = [];
set(a, 'Units', 'Pixels', 'XLim', [min(ts) max(ts)]);
set(a, 'Units', 'Normalized');


    function refresh()
        if isempty(pObj)
            pObj = patch(timestamps, data, 'r', 'Parent', a);
            set(pObj, 'EdgeColor', 'r');
        end
        
        lims = get(a, 'XLim');
        [wave times] = get_wave_data(lims(1), lims(2));
        %n_pixels = pos(3);
        
        refresh_plot(wave, times);
    end
    function pos = get_axes_position()
        switch get(a, 'Units');
            case 'normalized'
                set(a, 'Units', 'pixels');
                pos = get(a, 'Position');
                set(a, 'Units', 'normalized');
            case 'pixels'
                pos  = get(a, 'Position');
            otherwise
                disp(get(a,'Units'))
        end
    end

    function refresh_plot(wave, times)
        set(pObj, 'XData', times, 'YData', wave);
        %lim_vec = [min(wave)*7/8 max(wave)*9/8];
        %set(a, 'YLim', lim_vec);
    end

    function [wave times] =  get_wave_data(ts, te)
        ind1 = find(timestamps>ts, 1, 'first');
        ind2 = find(timestamps<te, 1, 'last');
        ind = ind1-10:ind2+10; % pad the data by 10 indecies for plotting
        ind = ind(ind>0 & ind<length(timestamps));
        ind = ind(ind>100 & ind<length(timestamps));
        n_points = length(ind);
        if (n_points>25000)
            ind = sort(randsample(ind,25000));
        end
        times = timestamps(ind);
        wave = data(ind);
        wave = [0 wave 0];
        times = [times(1) times times(end)];
    end
end