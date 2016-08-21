function handles = event_plot(events, varargin)
%EVENT_PLOT raster plot of events
%
%  EVENT_PLOT(events) plot events in a new figure.
%
%  EVENT_PLOT(events,parm1,val1,...) set optional parameters. Valid
%  parameters are:
%   Axis - when empty (default) a new figure & axis will be created,
%          otherwise specified axis will be used
%   YOffset - offset along the y-axis for each of the events; can be a
%             scalar (i.e. all events are overlayed, with the specified
%             y-offset) or a vector the same length as the number of events
%   Symbol - style of the symbol, one of + o * . x s d ^ v > < p h |
%            (default = |)
%   SymbolSize - size of the symbol (for |, the height of the symbol); can
%                be a scalar or a vector the same length as the number of
%                events. If a new axis is created, the default is 1,
%                otherwise the default is the height of the axis
%   Color - color of the symbols, specified as RGB value (default: [0 0 0],
%           i.e. black); either one color or as many colors as there are
%           events can be specified
%   XLim - limits of the x-axis (default: [], which means optimal scaling
%          for new axis or current x limits for existing axis)
%   Labels - cell array of event labels
%
%  h=EVENT_PLOT(...) returns graphics handles

%  Copyright 2005-2006 Fabian Kloosterman

handles = [];

Args = struct('Axis', [], 'YOffset', 0, 'SymbolSize', [], 'Color', [0 0 0], 'XLim', [], 'Symbol', '|', 'Labels', NaN);

if (nargin<1)
    help event_plot
    return
end

if iscell(events)
    nevents = length(events);
    for s = 1:nevents
        if (~isnumeric(events{s}) )
            error('event_plot:invalidArgument', 'Expecting a vector of event times')
        end
    end
else
    nevents=1;
    if (~isnumeric(events))
        error('event_plot:invalidArgument',  'Expecting a vector of event times')
    end
end

if (nargin>1)
    try
        Args = parseArgs(varargin, Args);
    catch
        error('event_plot:invalidArgument',  'Error parsing arguments')
    end
end

if isempty(Args.Axis)
    Args.Axis = axes;
    if isempty(Args.XLim)
        Args.XLim = [-Inf Inf];
    end
    if isempty(Args.YOffset)
        Args.YOffset = 0;
    end
    if isempty(Args.SymbolSize)
        Args.SymbolSize=1;
    end
elseif ~ishandle(Args.Axis)
    error 'Not a valid axis'
else
    yl = get(Args.Axis, 'YLim');
    if isempty(Args.YOffset)
        Args.YOffset = yl(1);
    end
    if isempty(Args.SymbolSize)
        Args.SymbolSize = yl(2)-yl(1);
    end
    if isempty(Args.XLim)
        Args.XLim = get(Args.Axis, 'XLim');
    end
end

if iscell(events) && isscalar(Args.YOffset)
    Args.YOffset = repmat(Args.YOffset, nevents, 1);
elseif length(Args.YOffset)~=nevents
    error('event_plot:invalidArgument',  'Wrong length of YOffset parameter')
end

if iscell(events) && isscalar(Args.SymbolSize)
    Args.SymbolSize = repmat(Args.SymbolSize, nevents, 1);
elseif length(Args.SymbolSize)~=nevents
    error('event_plot:invalidArgument',  'Wrong length of SymbolSize parameter')
end

if iscell(events) && size(Args.Color,1)==1
    Args.Color = repmat(Args.Color, nevents, 1);
elseif size(Args.Color,1)~=nevents
    error('event_plot:invalidArgument',  'Wrong length of EdgeColor parameter')
end

if iscell(events) && ischar(Args.Labels)
    Args.Labels = repmat( {Args.Labels}, nevents, 1);
elseif ~iscell(Args.Labels) && size(Args.Labels)~=nevents && ~isnan(Args.Labels)
    error('event_plot:invalidArgument',  'Invalid labels parameter')
end

axes(Args.Axis);

%transform object: potentially nice idea, but slows down plotting
%considerably
%tform_obj = hgtransform('Parent',Args.Axis,'Matrix',makehgtform);
tform_obj = Args.Axis;

if iscell(events)
    for c=1:nevents
        id = find(events{c}>=Args.XLim(1) & events{c}<=Args.XLim(2));
        if length(id)>0
            if strcmp(Args.Symbol,'|')
                l = line([events{c}(id) events{c}(id)]', [Args.YOffset(c) Args.YOffset(c)+Args.SymbolSize(c)], 'Color', Args.Color(c,:), 'Parent', tform_obj, 'HitTest', 'off');
            else
                l = line(events{c}(id), Args.YOffset(c), 'LineStyle', 'none', 'Marker', Args.Symbol, 'MarkerEdgeColor', Args.Color(c,:), 'MarkerSize', Args.SymbolSize(c), 'Parent', tform_obj, 'HitTest', 'off');
            end
            handles = [handles l(:)'];          
        end
    end
else
    id = find(events>=Args.XLim(1) & events<=Args.XLim(2));
    if length(id)>0
        if strcmp(Args.Symbol, '|')
            l = line([events(id) events(id)]', [Args.YOffset Args.YOffset+Args.SymbolSize], 'Color', Args.Color, 'Parent', tform_obj, 'HitTest', 'off');
        else
            l = line(events(id), Args.YOffset, 'LineStyle', 'none', 'Marker', Args.Symbol, 'MarkerEdgeColor', Args.Color, 'MarkerSize', Args.SymbolSize, 'Parent', tform_obj, 'HitTest', 'off');
        end
        handles = [handles l(:)'];
    end
end

if iscell(Args.Labels)
    if strcmp(Args.Symbol, '|')
        set(Args.Axis, 'YTick', Args.YOffset(:) + 0.5*Args.SymbolSize(:));
        set(Args.Axis, 'YTickLabel', Args.Labels);
    else
        set(Args.Axis, 'YTick', Args.YOffset);
        set(Args.Axis, 'YTickLabel', Args.Labels);
    end
end


if ~all(isinf(Args.XLim))
    set(Args.Axis, 'XLim', Args.XLim)
else
    set(Args.Axis, 'XLimMode', 'auto');
end

