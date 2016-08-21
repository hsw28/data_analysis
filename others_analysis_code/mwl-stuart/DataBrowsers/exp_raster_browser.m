function iObj = exp_raster_browser(cl, varargin)

args.Parent = [];
args.structure = 'all';
args.color = 'r';

args = parseArgs(varargin, args);

n_clust = length(cl);

if isempty(args.Parent) || isempty(axescheck(args.Parent))
    figure;
    a = axes();
    ts = min(cell2mat({cl.st}));
    te = max(cell2mat({cl.st}));
    set(a, 'Xlim', [ts te]);
else
    a = args.Parent;
end

xlim_listener = addlistener(a, 'XLim', 'PostSet', @(src,e) refresh);
iObj = [];

first_run =0;
check_cl();
refresh();


    function refresh()
       
        disp('Refreshing');
        if (~ishandle(a) | ~ishandle(iObj)) & first_run %#ok
            ishandle(a)
            ishandle(iObj)
            disp('Deleting');
            %delete(xlim_listener);
            %delete(iObj);
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
        disp('Calculate Image');
        x_dat = tstart:(tend-tstart)/x_pix:tend;
        x_dat = x_dat(1:end-1);
        tick_height = ceil(y_pix/n_clust);
        
        c_dat = zeros(floor(y_pix), floor(x_pix));
        for i=1:n_clust
            ind1 = find( cl(i).st>=tstart,1, 'first');
            ind2 = find( cl(i).st<=tend, 1, 'last');
            spikes = histc(cl(i).st(ind1:ind2), x_dat);
            if size(spikes,2)==size(c_dat,2)+1
                spikes = spikes(1:end-1);
            end

            spikes = (spikes>0);
            range = (i-1)*tick_height+1:i*tick_height;

            %new_dat = repmat(spikes, length(range),1);
            %disp(['c_dat size:', num2str(size(c_dat)), '  range:', num2str(range), '  new_dat size: ',num2str(size(new_dat))]);
            
            c_dat(range,:,1) = repmat(spikes, length(range),1);
            switch args.color
                case 'r'
                c_dat(:,:,2) = c_dat(:,:,1);
                c_dat(:,:,3) = 0;
                case 'y'
                c_dat(:,:,2:3) = 0;
                otherwise
                    error('Invalid color specified, only r and y are acceptable');
            end
        end      
        y_dat = 1:size(c_dat,2);
        
    end


    function refresh_plot(c,x,y)
        disp('Refresh Plots');
        if isempty(c)
            disp('No Data');
            return
        end
        size(c)
        size(x)
        size(y)
        if isempty(iObj)
            iObj = image(x,y,c, 'Parent', a);
        else
            set(iObj, 'CData', c, 'XData', x, 'YData',y);
        end
        set(a, 'YLim', [1 size(c,1)], 'YDir', 'Normal');
        first_run = 1;
    end

    function check_cl()
        disp('Checking Clusters');
        loc = {cl.loc};
        if isempty(args.structure) | strcmp(args.structure, 'all'); %#ok
            ind = logical(1:n_clust);
        else
            ind = ismember(loc, args.structure);
        end
        cl = cl(ind);
        n_clust = sum(ind);
                
        if n_clust>75
            cl = cl(randsample(n_clust, 75));
            n_clust = 75;
        end
        %for i = 1:n_clust
        %    cl(i).st = cl(i).st(:);
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

end