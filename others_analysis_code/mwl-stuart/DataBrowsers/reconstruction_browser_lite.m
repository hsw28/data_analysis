classdef reconstruction_browser_lite < uiwrapper
    
    properties
        clusters = [];  
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
        field_len = [];
        tuning_curves = [];
    end
    
    methods
        
        function obj = reconstruction_browser_lite(clusters, varargin)
            [hParent, args, nargs] = axescheck( varargin{:} );
           
            if isempty(hParent)
                hParent = gca; 
                disp('No Axes given using GCA');
            end
            
            excl_iface = {'Parent','XData', 'YData', 'CData'};
            obj = obj@uiwrapper(image(NaN,NaN,NaN,'Parent', hParent), [], excl_iface );
            obj.haxes = ancestor( hParent, 'axes');
            obj.xlim_listener = addlistener( obj.haxes, 'XLim', 'PostSet', @(src,e) refresh(obj) );
            
            obj.fig = ancestor(obj.haxes, 'Figure');
            obj.figure_listener = addlistener(obj.fig, 'Position','PostSet', @(src,e) refresh(obj) );
            
            
            obj.clusters = clusters;
            obj.field_len = length(obj.clusters(1).field1);
            obj.tuning_curves = nan(size(obj.clusters, 2), obj.field_len);
            for i=1:length(clusters)
                f1 = obj.clusters(i).field1/sum(obj.clusters(i).field1);
                f2  = obj.clusters(i).field1/sum(obj.clusters(i).field2);
                obj.tuning_curves(i,:) = [f1];% f2];
            end;
            min_t = [];
            max_t = [];
            for i=1:length(obj.clusters)
                min_t = min([min_t min(obj.clusters(i).time)]);
                max_t = max([max_t max(obj.clusters(i).time)]);
            end
            
            pan(obj.fig, 'xon')
            zoom(obj.fig, 'xon');
            
            set(obj.haxes, 'Units', 'Pixels');
            set(obj.haxes, 'XLim', [min_t max_t], 'YLim', [1 length(clusters)]);
            set(obj.haxes, 'Units', 'Normalized');
            set(obj.haxes, 'YTick', []);
            set(obj.haxes, 'XTick', []); 
            obj.CDataMapping= 'scaled';
            obj.color_map = colormap('hot');
        end
        
        function pdf = get_pdf(obj)
            pdf = obj.CData;
            
        end
        function set.color_map(obj, new_color_map)
            if size(new_color_map)~=[2,3]
                return;
            end
            obj.color_map = new_color_map;
            refresh(obj);
        end
                
        function refresh(obj)
            get_axes_position(obj);
            lims = get(obj.haxes, 'XLim');
            x_pix = obj.axes_position(3);
            y_pix = obj.axes_position(4);
            
            calculate_pdf(obj, lims(1), lims(2), x_pix);
            refresh_plot(obj);
        end
        
        
        function calculate_pdf(obj, tstart, tend, x_pix)
            warning off;
            
            tau = min([.3, (tend-tstart)/x_pix]);
            tau = max([tau, .01]);
            tau = .25;
            n = ceil((tend-tstart)/tau);
            disp(['Number of bins:', num2str(n)]);
            
            time_bins = generate_timestamps(tstart, tend, n);     
            
            n_spikes = zeros(length(obj.clusters), length(time_bins));
           
%           obj.CData = zeros(floor(y_pix), floor(x_pix));
   
            for i=1:length(obj.clusters)
                n_spikes(i,:) = histc(obj.clusters(i).time', time_bins);
            end; 
            
            pdf = parameter_estimation_simple(tau, obj.tuning_curves', n_spikes);
            
            %disp([num2str(size(tau)), ' ', num2str(size(obj.tuning_curves)), ' ', num2str(size(n_spikes(:,i)'))])
            warning on;
            %size(pdf);
            %obj.XData = x;
            obj.CData = pdf;
            obj.XData = time_bins;
            obj.YData = 1:size(obj.CData,1);
            %set(obj.haxes, 'XLim', [obj.XData(1), obj.XData(end)]);
            set(obj.haxes, 'YLim', [1, obj.YData(end)]);

        end
        
        function refresh_plot(obj)
            if isempty(obj.CData)
                disp('No Data');
                return
            end
                set(obj.hghandle, 'XData', obj.XData, 'YData', obj.YData, 'CData', obj.CData);
                %size(obj.CData)
                %set(obj.hghandle, 'CData', obj.CData);
                %colormap(obj.haxes, obj.color_map);
        end
               
        function get_axes_position(obj)
            obj.axes_position = get(obj.haxes, 'Position');
            if strcmp(get(obj.haxes, 'Units'), 'normalized')
                set(obj.haxes, 'Units', 'Pixels')
                obj.axes_position = get(obj.haxes, 'Position');
                set(obj.haxes, 'Units', 'normalized');
            end
        end    
        
    end
end