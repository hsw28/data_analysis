function env=define_env(env,varargin)

if nargin<2
    help mfilename
    return
end

%create buttons for adding nodes/edges/area if needed
%create and implement callbacks

options = struct( 'image', [], 'imagesize', [], 'position', [] );
options = parseArgs(varargin,options);

%check image
if ~isempty(options.image)
  
  if ~isnumeric(options.image) || ndims(options.image)>3
    error('define_env:invalidArgument', 'Invalid image')
  elseif size(options.image,3)>1
    options.image = rgb2gray(options.image);
  end
  
  if isempty(options.imagesize)
    options.imagesize = [0 0 ; fliplr(size(options.image))-1]';
  elseif ~isnumeric(options.imagesize) || ndims(options.imagesize)>2 || ...
        ~isequal(size(options.imagesize),[2 2])
    error('define_env:invalidArgument', 'Invalid image size')
  end
  
end

if ~isempty(options.position) && (~isnumeric(options.position) || ndims(options.position)>2 ...
                              || size(options.position,2)~=2)
  error('define_env:invalidArgument', 'Invalid position data')
end

%set up figure / axes / controls
hFig = figure('colormap',gray(256), 'DeleteFcn', @figure_delete);
hAx = axes('Units', 'normalized', 'Position', [0.1 0.1 0.6 0.8], 'Parent', hFig);

%plot image and position data
if ~isempty(options.image)
  hImg = imagesc( 'XData', options.imagesize(1,:), 'YData', options.imagesize(2,:), ...
                  'CData', options.image, 'parent', hAx, 'hittest', 'off'); %#ok
end
if ~isempty(options.position)
  hData = line( options.position(:,1), options.position(:,2), 'parent', hAx, 'color', [1 0.5 0.25], 'hittest', 'off'); %#ok
end

%draw existing environment
switch env.type
    case {'simple track','complex track'}
        handles.Nodes(1:2) = draw_rectangles(env.nodes(1:2),[0 0 1],'ContextDelete',false);
        if numel(env.nodes)>2
            handles.Nodes(3:numel(env.nodes)) = draw_rectangles(env.nodes(3:end),[0 0 0.8],'ContextDelete',true);
        end
        handles.Edges(1) = draw_polylines(env.edges(1), [0 1 0],'ContextDelete',false);
        if numel(env.edges)>1
            handles.Edges(2:numel(env.edges)) = draw_polylines(env.edges(2:end), [0 0.8 0],'ContextDelete',true);
        end
    case 'circular track'
        handles.Edges = draw_circles(env.edges,[0 1 0],'ContextDelete',false);
    case 'rectangular track'
        handles.Edges = draw_rectangles(env.edges,[0 1 0],'ContextDelete',false);
    case 'closed track'
        handles.Edges = draw_polylines(env.edges,[0 1 0],'ContextDelete',false);
    case 'circular field'
        handles.Outline = draw_circles(env.outline, [1 0 0],'ContextDelete',false);
        handles.Areas.Polylines = draw_polylines(env.areas.polylines, [0 1 1],'ContextDelete',true);
        handles.Areas.Circles = draw_circles(env.areas.circles, [0 1 1],'ContextDelete',true);
        handles.Areas.Rectangles = draw_rectangles(env.areas.rectangles, [0 1 1],'ContextDelete',true);
    case 'rectangular field'
        handles.Outline = draw_rectangles(env.outline,[1 0 0],'ContextDelete',false);
        handles.Areas.Polylines = draw_polylines(env.areas.polylines, [0 1 1],'ContextDelete',true);
        handles.Areas.Circles = draw_circles(env.areas.circles, [0 1 1],'ContextDelete',true);
        handles.Areas.Rectangles = draw_rectangles(env.areas.rectangles, [0 1 1],'ContextDelete',true);
    case 'custom field'
        handles.Outline = draw_polylines(env.outline,[1 0 0],'ContextDelete',false);
        handles.Areas.Polylines = draw_polylines(env.areas.polylines, [0 1 1],'ContextDelete',true);
        handles.Areas.Circles = draw_circles(env.areas.circles, [0 1 1],'ContextDelete',true);
        handles.Areas.Rectangles = draw_rectangles(env.areas.rectangles, [0 1 1],'ContextDelete',true);
end

% create buttons
switch env.type
    case 'complex track'
        hBtn(1) = uicontrol('Units', 'normalized', 'Position', [0.75 0.8 0.2 0.1], ...
            'Parent', hFig, 'String', 'Add node', 'Callback', @addNode );
        hBtn(2) = uicontrol('Units', 'normalized', 'Position', [0.75 0.65 0.2 0.1], ...
            'Parent', hFig, 'String', 'Add connection', 'Callback', @addConnection);
    case {'circular field', 'rectangular field', 'custom field'}
        hBtn(1) = uicontrol('Units', 'normalized', 'Position', [0.75 0.8 0.2 0.1], ...
            'Parent', hFig, 'String', 'Add circ. area', 'Callback', @addCircle);
        hBtn(2) = uicontrol('Units', 'normalized', 'Position', [0.75 0.65 0.2 0.1], ...
            'Parent', hFig, 'String', 'Add rect. area', 'Callback', @addRectangle);
        hBtn(3) = uicontrol('Units', 'normalized', 'Position', [0.75 0.5 0.2 0.1], ...
            'Parent', hFig, 'String', 'Add polygon area', 'Callback', @addPolygon);
end

% wait until user is done
uiwait(hFig);

    function figure_delete(hObj, eventdata) %#ok
        
        switch env.type
            case {'simple track', 'complex track'}
                for k=1:numel(handles.Nodes)
                    env.nodes(k,1) = struct( 'center', handles.Nodes{k}.Center, 'size', handles.Nodes{k}.Size, 'rotation', handles.Nodes{k}.Rotation, 'name', handles.Nodes{k}.Name );
                end
                for k=1:numel(handles.Edges)
                    env.edges(k,1) = struct( 'vertices', handles.Edges{k}.Vertices, 'isclosed', handles.Edges{k}.Closed, 'isspline', handles.Edges{k}.Spline );
                end
            case 'circular track'
                env.edges = struct( 'center', handles.Edges{1}.Center, 'radius', handles.Edges{1}.Radius );
            case 'rectangular track'
                env.edges = struct( 'center', handles.Edges{1}.Center, 'size', handles.Edges{1}.Size, 'rotation', handles.Edges{1}.Rotation );
            case 'closed track'
                env.edges = struct( 'vertices', handles.Edges{1}.Vertices, 'isclosed', handles.Edges{1}.Closed, 'isspline', handles.Edges{1}.Spline );
            case 'circular field'
                env.outline = struct( 'center', handles.Outline{1}.Center, 'radius', handles.Outline{1}.Radius );
            case 'rectangular field'
                env.outline = struct( 'center', handles.Outline{1}.Center, 'size', handles.Outline{1}.Size, 'rotation', handles.Outline{1}.Rotation );
            case 'custom field'
                env.outline = struct( 'vertices', handles.Outline{1}.Vertices, 'isclosed', handles.Outline{1}.Closed, 'isspline', handles.Outline{1}.Spline );
        end
        if any(strcmp(env.type,{'circular field','rectangular field','custom field'}))
            for k=1:numel(handles.Areas.Polylines)
                env.areas.polylines(k,1) = struct( 'vertices', handles.Areas.Polylines{k}.Vertices, 'isclosed', handles.Areas.Polylines{k}.Closed, 'isspline', handles.Areas.Polylines{k}.Spline, 'name', handles.Areas.Polylines{k}.Name );
            end
            for k=1:numel(handles.Areas.Circles)
                env.areas.circles(k,1) = struct( 'center', handles.Areas.Circles{k}.Center, 'radius', handles.Areas.Circles{k}.Radius, 'name', handles.Areas.Circles{k}.Name );
            end
            for k=1:numel(handles.Areas.Rectangles)
                env.areas.rectangles(k,1) = struct( 'center', handles.Areas.Rectangles{k}.Center, 'size', handles.Areas.Rectangles{k}.Size, 'rotation', handles.Areas.Rectangles{k}.Rotation, 'name', handles.Areas.Rectangles{k}.Name );
            end
        end
        
    end

    function addNode(h,e) %#ok
        xl = get( hAx, 'XLim' );
        yl = get( hAx, 'YLim' );
        handles.Nodes(end+1) = draw_rectangles( struct('center', [mean(xl) mean(yl)], 'size', 0.1*[diff(xl) diff(yl)], 'rotation', 0),[0 0 0.8],'ContextDelete',true);
    end
    function addConnection(h,e) %#ok
        xl = get( hAx, 'XLim' );
        yl = get( hAx, 'YLim' );
        handles.Edges(end+1) = draw_polylines( struct('vertices', [xl(1)+0.25*diff(xl) yl(1)+0.25*diff(yl) ; xl(1)+0.75*diff(xl) yl(1)+0.75*diff(yl)], 'isclosed', false, 'isspline', false), [0 0.8 0],'ContextDelete',true,'ContextClose',false);
    end
    function addCircle(h,e) %#ok
        xl = get( hAx, 'XLim' );
        yl = get( hAx, 'YLim' );
        handles.Areas.Circles(end+1) = draw_circles( struct('center', [mean(xl) mean(yl)], 'radius', 0.1*sqrt(diff(xl).^2 + diff(yl).^2) ), [0 1 1], 'ContextDelete', true );
    end
    function addRectangle(h,e) %#ok
        xl = get( hAx, 'XLim' );
        yl = get( hAx, 'YLim' );
        handles.Areas.Rectangles(end+1) = draw_rectangles( struct('center', [mean(xl) mean(yl)], 'size', 0.1*[diff(xl) diff(yl)], 'rotation', 0),[0 1 1],'ContextDelete',true);
    end
    function addPolygon(h,e) %#ok
        xl = get( hAx, 'XLim' );
        yl = get( hAx, 'YLim' );
        handles.Areas.Polylines(end+1) = draw_polylines(struct('vertices', [xl(1)+0.25*diff(xl) yl(1)+0.25*diff(yl) ; xl(1)+0.75*diff(xl) yl(1)+0.75*diff(yl) ; xl(1)+0.25*diff(xl) yl(1)+0.75*diff(yl)], 'isclosed', true, 'isspline', false), [0 1 1],'ContextDelete',true,'ContextClose',false);
    end

    function h=draw_circles(s,col,varargin)
        h = cell(numel(s),1);
        for k=1:numel(s)
            if isfield(s(k),'name')
                name = s(k).name;
            else
                name='';
            end
            h{k} = Circle(s(k).center, s(k).radius, 'parent', hAx, 'EdgeColor', col, 'Name', name, varargin{:} );
        end
    end
    function h=draw_rectangles(s,col,varargin)
        h = cell(numel(s),1);
        for k=1:numel(s)
            if isfield(s(k),'name')
                name = s(k).name;
            else
                name='';
            end
            h{k} = Rect(s(k).center, s(k).size, s(k).rotation, 'parent', hAx, 'EdgeColor', col, 'Name', name, varargin{:}  );
        end
    end
    function h=draw_polylines(s,col,varargin)
        h = cell(numel(s),1);
        for k=1:numel(s)
            if isfield(s(k),'name')
                name = s(k).name;
            else
                name='';
            end
            h{k} = Polyline(s(k).vertices, s(k).isclosed, s(k).isspline, 'parent', hAx, 'Color', col, 'Name', name, 'NVertices', [2 Inf], varargin{:}  );
        end
    end



end
