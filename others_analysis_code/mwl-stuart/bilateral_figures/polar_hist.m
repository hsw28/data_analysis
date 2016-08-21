function [h, ax] = polar_hist(ax, data, bins,  normalize)

% if the first input argument isn't an axes object, then shift the values
% of the input args appropriately

if isempty( axescheck(ax) )
    
    if nargin==4
        error('Invalid axes handle provided');
    end
    
    if nargin>=3
        normalize = bins;
    end
    
    if nargin>=2
        bins = data;
    end
    
    if nargin>=1
        data = ax;
        ax = [];
    end
end

if ~exist('bins', 'var') || isempty(bins)
    bins = -(pi * 7/8 ) : pi/8 : pi;
elseif ~isvector(bins) && ~ismonotonic(bins)
    error('bins must be a monotonically increasing vector');
end

if ~exist('normalize', 'var') || isempty(normalize)
    normalize = 0;
elseif ~isscalar(normalize) && any(normalize == [0 1])
    error('normalize must be equal to 0 or 1');
end



% Compute the histogram counts.
[t, r] = rose(data, bins);

if normalize == 1
    r = r ./ sum(r) ;
end

[x,y] = pol2cart(t,r);

% save the largest radius in the histogram
R = max(r) * 1;

if isempty(ax)
    ax = createPolarAxes(R); 
end

h = patch(x,y,'b', 'parent', ax, 'linewidth', 2);

data = get(ax, 'UserData');

if isempty(data)
     data = struct('hObj', []);
end

data.hObj(end+1) = h;

%uistack(data.handles.rLabel, 'top');

set(ax,'UserData', data);


end



function data = checkIfPolarAxes(ax)
    data = get(ax,'UserData');
    if isempty(data) || ~isfield(data, 'type') || ~strcmp(data.type, 'polar')
        error('The Axes object is not configured as a polar axes');
    end

end

function ax = createPolarAxes(R)
    disp('Creating a new polar axes');
    %create the figure
    f = figure;
    ax = axes('Parent', f, 'Units', 'pixels');
    
    % make the Axes square in pixel space
    fPos = get(f, 'Position');
    dim = min( fPos(3:4) );
    
    axPos = [ ...
        (fPos(3) - dim)/2 + 5,  ...
        (fPos(4) - dim)/2 + 5, ...
        dim - 40, dim - 40];
    
    % set the values on the axes
    set(ax,'Position', axPos , 'Color', 'none', 'Units', 'normal');
    set(ax, 'XTick', [], 'YTick', [], 'XLim', R * [-1.2 1.2], 'Ylim', R * [-1.2 1.2]);
       
    % save the parameters for later access
    data.type = 'polar';
    
    data.R = R;
    
    data.hObj = [];
    
    set(ax,'UserData', data);
    
    renderPolarAxes(ax);
end

function renderPolarAxes(ax)

    data = checkIfPolarAxes(ax);
      
     % Render the OUTER ring
    data.handles.polarAxes = ...   
    circle(ax, [0 0], data.R, 'edgecolor', 'k', 'linewidth', 2, 'facecolor', 'w');
    
    % Render the ANGULAR ticks and labels
    [data.handles.aTick, data.handles.aLabel] = ...
        renderAngularTicks(ax, data.R);
    
    % Render the RADIAL ticks and labels
    [data.handles.rTick, data.handles.rLabel] = ...
        renderRadialTicks(ax, data.R);
    
    set(ax,'UserData', data);
   
end

function [tick, lab] = renderRadialTicks(ax, R)
    % draw the maxes marks
   
    for i = 1:3
       r = R * i/3;
       [x, y] = pol2cart(pi/4, r );
       
       tick(i) = circle([0 0], r, 'EdgeColor', [.4 .4 .4], 'FaceColor', 'none', 'linestyle', '--', 'Parent', ax);
       lab(i) = text(x, y, sprintf('%3.2f', r), 'FontSize', 14);
   
    end
    
end

function [tick, lab] = renderAngularTicks(ax, R)

    
    tick(1) = line(R * [-1, 1], [0, 0], 'color', 'k', 'parent', ax);
    tick(2) = line([0, 0], R * [-1, 1], 'color', 'k', 'parent', ax);
    tick(3) = line(sqrt(2)/2 * [-R R], sqrt(2)/2 * [R -R], 'color', 'k', 'parent', ax);
    tick(4) = line(sqrt(2)/2 * [R -R], sqrt(2)/2 * [R -R], 'color', 'k', 'parent', ax);

    lab(1) = text(1.05*R, 0, '2\pi',      'fontsize', 14, 'HorizontalAlignment', 'left', 'verticalalignment', 'middle');
    lab(2) = text(-1.075*R, 0, '\pi',     'fontsize', 14, 'HorizontalAlignment', 'right','verticalalignment', 'middle');
    lab(3) = text(0, 1.05*R, '\pi/_2',    'fontsize', 14, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
    lab(4) = text(0, -1.05*R, '3\pi/_2', 'fontsize', 14, 'horizontalalignment', 'center', 'verticalalignment', 'top');

    
end