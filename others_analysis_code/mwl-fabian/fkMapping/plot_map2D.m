function ax = plot_map2D(m, varargin)
%PLOT_MAP2D pretty plot of a 2D matrix
%
%  PLOT_MAP2D(m) plot image of matrix
%
%  PLOT_MAP2D(m, parm1, val1, ...) specify additional parameter/value
%  arguments to set plotting options. Valid parameters are:
%   ReplacePatch - handle of patch object that should be replaced
%   MapCenters - centers of map elements
%   MapEdges -  edges of map elements
%   Image - optional background image
%   ImageSize - image size (in axes coordinates)
%   Parent - parent axes, figure or uipanel
%   ColorMap - vector of colors (default = hot(256))
%   Scale - color scale
%   Alpha - alpha value for map
%   ImageAlpha - alpha value for background image
%   BackgroundColor - optional background color
%   Title - axes title
%   Labels - labels for x axis, y axis and colorbar
%   ColorBar - 0/1 hide/show colorbar
%
%  hAx=PLOT_MAP2D(...) returns the handle to the axes
%
%  This function will plot a nice image of a matrix. Matrix elements that
%  have a value of NaN are not plotted (i.e. transparent). 
%
%  See also IMAGE2PATCH
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<1
    help(mfilename)
    return
end

[r, c, p] = size(m); %#ok

if p>1
    m = m(:,:,1);
end


args = struct('ReplacePatch', [], 'MapCenters', [], 'MapEdges', [], 'Image', [], 'ImageSize', [0 0; 0 0], 'Parent', [], 'ColorMap', hot(256), 'Scale', [ nanmin(m(:)) nanmax(m(:)) ], 'Alpha', 1, 'ImageAlpha', 1, 'BackgroundColor', [0 0 0], 'Title', NaN, 'Labels', NaN, 'Colorbar', 0);
args = parseArgs(varargin, args);

if isinf( args.Scale(1) )
    args.Scale(1) = min(m(:));
end
if isinf( args.Scale(2) )
    args.Scale(2) = max(m(:));
end
if args.Scale(1)==args.Scale(2)
    args.Scale(2) = args.Scale(2)+0.01;
end

if isempty(args.Parent)
    ax = gca;    
elseif ishandle(args.Parent) && strcmp( get(args.Parent, 'Type'), 'axes')
    ax = args.Parent;
elseif ishandle(args.Parent) && ismember( get(args.Parent, 'Type'), {'figure', 'uipanel'} )
    ax = axes('Parent', args.Parent);
else
    error('Invalid parent')
end

if ischar(args.Labels)
    args.Labels = {args.Labels args.Labels, ''};
elseif iscell(args.Labels) && numel(args.Labels)==1
    args.Labels(2) = args.Labels(1);
    args.Labels{3} = '';
elseif iscell(args.Labels) && numel(args.Labels)==2
    args.Labels{3} = '';
elseif isnumeric(args.Labels) && isnan(args.Labels)
    args.Labels = {NaN, NaN, NaN};
end

%reset and clean axes
%cla(ax);
%reset(ax);


%plot image in parent axes
if ~isempty(args.Image)
    image(args.ImageSize(1,:), args.ImageSize(2,:), args.Image, 'Parent', ax, 'AlphaData', args.ImageAlpha);
end

hold(ax, 'on');

if ~isnan(args.Title)
    title(ax, args.Title);
end
if ~isnan(args.Labels{1})
    xlabel(ax, args.Labels{1});
end
if ~isnan(args.Labels{2})
    ylabel(ax, args.Labels{2});
end

set(ax, 'Color', args.BackgroundColor);

%prepare map
%create patches
[vert, fac, tcol] = image2patch(m', 'Centers', args.MapCenters, 'Edges', args.MapEdges);
%convert tcol to indices into colormap
if diff(args.Scale)==0
    tcol = ones(size(tcol));
else
    tcol = round( (size(args.ColorMap,1) - 1) .* (tcol - args.Scale(1)) ./ diff(args.Scale) + 1 );
    tcol( tcol<1 ) = 1;
    tcol( tcol>size(args.ColorMap,1) ) = size(args.ColorMap,1);
end

%plot map
if size(fac,1)>0
    if ~isempty(args.ReplacePatch) && ishandle(args.ReplacePatch) && strcmp( get(args.ReplacePatch, 'Type'), 'patch') && get( args.ReplacePatch, 'Parent')==ax
        pos = get( ax, 'Position');
        set( args.ReplacePatch, 'Faces',fac,'Vertices',vert,'FaceVertexCData',args.ColorMap(tcol,:), 'FaceColor','flat', 'EdgeColor', 'none', 'FaceAlpha', args.Alpha);
        set(ax, 'Position', pos);
        %delete(args.ReplacePatch)
        %p = patch('Faces',fac,'Vertices',vert,'FaceVertexCData',args.ColorMap(tcol,:),'FaceColor','flat', 'EdgeColor', 'none', 'Parent', ax, 'FaceAlpha', args.Alpha);
    elseif isempty(args.ReplacePatch)
        p = patch('Faces',fac,'Vertices',vert,'FaceVertexCData',args.ColorMap(tcol,:),'FaceColor','flat', 'EdgeColor', 'none', 'Parent', ax, 'FaceAlpha', args.Alpha);%#ok
    else
    end
end

hold(ax, 'off');


%create colorbar
if args.Colorbar
    drawnow() %work around for the warning "RGB color data not yet supported in Painter's mode."
    %find if axis has colorbar
    hc = [];
    p = get( ax, 'Parent' );
    child_axes = findobj( get(p, 'Children'), 'flat', 'Type', 'axes');
    for k=1:numel(child_axes)
        if isa(handle(child_axes(k)),'scribe.colorbar') && double(handle(child_axes(k)))==ax;
            hc = child_axes(k);
            break;
        end
    end
    
    if isempty(hc)
        hc = colorbar('peer', ax);
    end
    
    hi = get(hc, 'Children');

    if ~isnan(args.Labels{3})
        ylabel(hc, args.Labels{3});
    end
    set(hc, 'YLim', args.Scale);
    set(hi, 'YData', args.Scale);
    set(hi, 'CData', permute(args.ColorMap, [1 3 2]));
    set(hc, 'XColor', [0 0 0], 'YColor', [0 0 0]);
end

