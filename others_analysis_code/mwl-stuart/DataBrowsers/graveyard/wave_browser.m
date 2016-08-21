classdef wave_browser < uiwrapper
    
    properties
        wave = [];
        times = [];
        offset = 0;
    end
    
    properties (Access=protected)
        xlim_listener = handle([]); % listener attached to XLim property of parent axes
        haxes = []; % parent axes handle
        fig = [];
        figure_listener = handle([]);
        axes_position = [];
        XData = [];
        YData = [];
    end
    
    methods
        
        function obj = wave_browser(wave, times, varargin)
            [hParent, args, nargs] = axescheck( varargin{:} );
            if isempty(hParent)
                hParent = gca();   
                disp('No Axes given using GCA');
            end
            
            excl_iface = {'Parent','XData', 'YData'};
            obj = obj@uiwrapper(line(NaN,NaN,'Parent', hParent), [], excl_iface );
            obj.haxes = ancestor( hParent, 'axes');
            obj.xlim_listener = addlistener( obj.haxes, 'XLim', 'PostSet', @(src,e) refresh(obj) );
            
            obj.wave = wave;
            obj.times = times;
            
            
            set(obj.haxes, 'Units', 'Pixels');
            set(obj.haxes, 'XLim', [min(times) max(times)]);
            set(obj.haxes, 'Units', 'Normalized');
        end
        function refresh(obj)
            get_axes_position(obj);
            lims = get(obj.haxes, 'XLim');
            n_pixels = obj.axes_position(3);
            
            [obj.YData, obj.XData] = get_wave_data(obj, lims(1), lims(2));
            refresh_plot(obj);
        end       
        function get_axes_position(obj)
            obj.axes_position = get(obj.haxes, 'Position');
            if strcmp(get(obj.haxes, 'Units'), 'normalized')
                set(obj.haxes, 'Units', 'Pixels')
                obj.axes_position = get(obj.haxes, 'Position');
                set(obj.haxes, 'Units', 'normalized');
            end
        end
        function refresh_plot(obj)
            if numel(obj.XData)~=numel(obj.YData) || isempty(obj.XData) || isempty(obj.YData)
                set( obj.hghandle, 'XData', NaN, 'YData', NaN );    
                %disp('No Data');
            else 
                set(obj.hghandle, 'XData', obj.XData, 'YData', obj.YData + obj.offset);
                lim_vec = [min(obj.YData + obj.offset)*7/8 max(obj.YData + obj.offset)*9/8];
                set(obj.haxes, 'YLim', lim_vec);
            end
        end
        function set.offset(obj, new_offset)
            obj.offset = new_offset;
        end
        function [wave times] =  get_wave_data(obj, ts, te)
            ind1 = find(obj.times>ts, 1, 'first');
            ind2 = find(obj.times<te, 1, 'last');
            ind = ind1:ind2;
            n_points = length(ind);
            if (n_points>25000)
                ind = sort(randsample(ind,25000));

            end    
                times = obj.times(ind);
                wave = obj.wave(ind);          
        end
        function [x y] = get_data(obj)
            x = obj.XData;
            y = obj.YData;
        end
    end
end