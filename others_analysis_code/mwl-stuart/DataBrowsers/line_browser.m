function lineHandle = line_browser(timestamps, data, varargin)
% line_browser(data, ts, varargin), returns handles to line objects that
% are plotted dynamically

args.color = 'b';
args.parent = [];
args.offset = 0;
args = parseArgs(varargin, args);
a = axescheck(args.parent);

if isempty(a) 
    figure();
    a = axes();
    disp('No Axes specified, creating them');
end

if nargin == 1
    data = timestamps;
    timestamps = 1:length(data);
end

if ismatrix(data) && size(data,1)>1 && numel(args.color)==1
    args.color = repmat(args.color, size(data,1),1);
end

if isvector(data) && size(data,2)>size(data,1)
    data = data';
end

if args.offset~=0
    for idx=1:size(data,2)
        data(:,idx)= data(:,idx)+args.offset*idx;
    end
end

xlim_listener = addlistener(a, 'XLim', 'PostSet', @(src,e) refresh);
dest_listener = addlistener(a, 'ObjectBeingDestroyed', @(src, e) destroy);

lineHandle = [];

set(a, 'Units', 'Pixels', 'XLim', [min(timestamps) max(timestamps)]);
set(a, 'Units', 'Normalized');


    function refresh()
       
        if ~ishandle(a) | ~ishandle(lineHandle) %#ok
            delete(xlim_listener);
            if ishandle(lineHandle)
                delete(lineHandle);
            end
            return
        end
        
        if isempty(lineHandle)
            for i=1:size(data,2)
                if isvector(args.color)
                    c_tmp = args.color(i);
                else
                    c_tmp = args.color(i,:);
                end
                lineHandle(i) = line([1],[1], 'Parent', a,'color', c_tmp);
            end
        end
        
        lims = get(a, 'XLim');
        [wave times] = get_wave_data(lims(1), lims(2));
        refresh_plot(wave, times);
    end

    function refresh_plot(wave, times)        
        for i=1:size(data,2)
            set(lineHandle(i), 'XData', times, 'YData', wave(:,i));
        end
    end

    function [wave times] =  get_wave_data(ts, te)
        
        ind1 = find(timestamps>ts, 1, 'first');
        ind2 = find(timestamps<te, 1, 'last');       
        ind1 = max([ind1-30, 1]);
        ind2 = min([ind2+30, numel(timestamps)]);
        
        ind = ind1:ind2;
        %ind = ind(ind>100 & ind<length(timestamps));
        n_points = length(ind);
        if (n_points>25000)
            ind = sort(randsample(ind,25000));
        end
        times = timestamps(ind);
        
        wave = data(ind,:);
    end

    function destroy()
       %disp('object getting destroyed');
       if ishandle(xlim_listener)
        delete(xlim_listener)
       end
       delete(dest_listener)
        
    end

end