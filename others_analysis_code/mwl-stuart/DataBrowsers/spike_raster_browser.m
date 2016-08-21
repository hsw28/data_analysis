function iObj = spike_raster_browser(clust, varargin)

[a args] = axescheck(varargin{:});
if isempty(a)
    f = figure;
    a = axes();
    disp('No Axes specified');
end

clusters = clust;
n_clust = length(clusters);
xlim_listener = addlistener(a, 'XLim', 'PostSet', @(src,e) refresh);
iObj = [];

ts = min(cellfun(@min, {clusters.st}));
te = max(cellfun(@max, {clusters.st}));
set(a, 'Xlim', [ts te]);

check_clusters();

    function refresh()
        if ~ishandle(a) | ~ishandle(iObj)
            delete(xlim_listener);
            delete(iObj);
            return
        end
        lims = get(a, 'XLim');
        ax_pos = get_axes_position();
        x_pix = ax_pos(3);
        y_pix = ax_pos(4);

        [c, x, y] = calculate_img(lims(1), lims(2), x_pix, y_pix);
        refresh_plot(c, x, y);
        set(a, 'YLim', [0 size(c,1)]);
      
    end

    function [c_dat, x_dat, y_dat] = calculate_img(tstart, tend, x_pix, y_pix)
        x_dat = tstart:(tend-tstart)/x_pix:tend;
        x_dat = x_dat(1:end-1);
        tick_height = ceil(y_pix/n_clust);
        y_dat = []; %1:tick_height:length(obj.clusters);

        c_dat = zeros(floor(y_pix), floor(x_pix));
        for i=1:n_clust
            ind1 = find( clusters(i).st>=tstart,1, 'first');
            ind2 = find( clusters(i).st<=tend, 1, 'last');
            spikes = histc(clusters(i).st(ind1:ind2), x_dat);
            if size(spikes,2)==size(c_dat,2)+1
                spikes = spikes(1:end-1);
            end

            spikes = spikes(:);
            spikes = (spikes>0)*25;
            range = (i-1)*tick_height+1:(i)*tick_height;

            new_dat = repmat(spikes, length(range),1);
           % disp(['c_dat size:', num2str(size(c_dat)), '  range:', num2str(range), '  new_dat size: ',num2str(size(new_dat))]);
           c_dat(range,:) = repmat(spikes', numel(range),1);
        end      
    end


    function refresh_plot(c,x,y)
        if isempty(c)
            disp('No Data');
            return
        end
        
        if isempty(iObj)
            iObj = image(x,y,c, 'Parent', a);
        else
            set(iObj, 'CData', c, 'XData', x, 'YData',y);
        end
        set(a, 'YLim', [1 size(c,1)], 'YDir', 'Normal');
    end

    function check_clusters()
        if n_clust>75
            clusters = clusters(randsample(n_clust, 75));
            n_clust = 75;
        end
        %for i = 1:n_clust
        %    clusters(i).st = clusters(i).st(:);
        %end
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
                disp(get(a,'Units'));
        end
    end    





%{

    properties

        color_map = [1 1 1; 0 0 0];
    end
    
    properties (Access=protected)
        xlim_listener = handle([]); % listener attached to XLim property of parent axes
        haxes = []; % parent axes handle
        fig = [];
        figure_listener = handle([]);
        axes_position = [];
        CData = [];
        XData = [];
        YData = [];
    end
    
    methods
        function obj = spike_raster_browser(clusters, varargin)
          
        
        
               
        
        
    end
%}
end