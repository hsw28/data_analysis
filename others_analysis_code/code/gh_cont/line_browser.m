function aObj = line_browser(data, ts, varargin)


[a args]= axescheck(varargin{:});

if isempty(a)
    f = figure();
    a = axes();
    disp('No Axes specified, creating them');
end

data = data;
timestamps = ts;
a_pos = [];

xlim_listener = addlistener(a, 'XLim', 'PostSet', @(src,e) refresh);
aObj = [];
set(a, 'Units', 'Pixels', 'XLim', [min(ts) max(ts)]);
set(a, 'Units', 'Normalized');


    function refresh()
        if isempty(aObj)
            aObj = line(timestamps, data, 'Parent', a);
        end
        pos = get_axes_position();
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
        set(aObj, 'XData', times, 'YData', wave);
        %lim_vec = [min(wave)*7/8 max(wave)*9/8];
        %set(a, 'YLim', lim_vec);
    end

    function [wave times] =  get_wave_data(ts, te)
        ind1 = find(timestamps>ts, 1, 'first');
        ind2 = find(timestamps<te, 1, 'last');
        ind = ind1:ind2;
        ind = ind(ind>100 & ind<length(timestamps));
        n_points = length(ind);
        if (n_points>25000)
            ind = sort(randsample(ind,25000));
        end
        times = timestamps(ind);
        wave = data(ind);
    end
end