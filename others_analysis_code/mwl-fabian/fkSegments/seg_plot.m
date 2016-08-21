function h = seg_plot(segments, varargin)
%SEG_PLOT plot segments
%
%  SEG_PLOT(segments) plots segments (either a matrix of segments or a
%  cell array with segment lists) in a new axis in the current
%  figure. Segments containing -Inf or Inf are not drawn.
%
%  h=SEG_PLOT(segments) returns for every segment list the handles of the
%  plot objects.
%
%  h=SEG_PLOT(segments,parm1,val1,...) sets optional parameters. Valid
%  parameters are:
%   Axis - handle of destination axes (default = [] (new axes) ).
%   XLim - x axis limits (default = []; if 'Axis' parameter is specified
%          this will leave x limits unchanged, if a new axes is created
%          this will set the x limits to show all the segments).
%   PlotArea - segments are plotted as two vertical lines, connected by a
%              horizontal line (PlotArea=0) or as rectangles (PlotArea=1)
%              with optional fill color and alpha value. (default = 1).
%   YOffset - y offset of bottom of rectangles or of horizontal line
%             segments (default = []; if 'Axis' parameter is specified
%             this will be set to the lower y axis limit, if a new axes
%             is created this will be 0). If segments is a cell array,
%             YOffset can also be an array of the same length, specifying
%             variable offsets for each segment list.
%   Height - height of rectangles or vertical line segments (default =
%            []; if 'Axis' parameter is specified this will be set to
%            (max y limit - YOffset), otherwise it is set to 1). If
%            segments is a cell array, Height can also be an array of the
%            same length, specifying variable heights for each segment
%            list.
%   FaceColor - 1x3 vector specifying the color (rgb) of the segment
%               rectangles. If segments is a cell array, FaceColor can
%               also be a nx3 array (n = length of cell array),
%               specifying variable colors for each segment
%               list. (default = [1 0 0]). This parameter is only used
%               when PlotArea = 1.
%   EdgeColor - 1x3 vector specifying the color (rgb) of lines. If
%               segments is a cell array, EdgeColor can also be a nx3
%               array (n = length of cell array), specifying variable
%               edge colors for each segment list. (default = 'none').
%   Alpha - Scalar specifying the alpha value for segment rectangles. If
%           segments is a cell array, Alpha can also be an array of the
%           same length, specifying variable alphas for each segment
%           list. (default = 0.5). This parameter is only used when
%           PlotArea = 1.
%   LineWidth - width of lines (default = 2). This parameter is only used
%               when PlotArea = 0.
%   LineStyle = style of lines (default = '-'). This parameter is only used
%               when PlotArea = 0.
%   SegNames = cell array of segment names, same length as the number of
%              segment lists (default = {''}).
%   TextOffset - Verical offset of text, relative to bottom of segment
%                rectangles or horizontal lines (default = 0).
%   ShowText - 0/1 hide/show segment names (default = 0).
%   TextColor - Color of text, either a single RGB value or a matrix of
%               RGB values to specify color for each segment separately
%               (default = [], which means the same as EdgeColor).
%

%  Copyright 2005-2008 Fabian Kloosterman

h=[];

Args = struct('Axis', [], 'XLim', [], 'YOffset', [], 'Height', [], 'FaceColor', [], 'Alpha', 1, 'EdgeColor', 'none', 'LineWidth', 2, 'LineStyle', '-', 'SegNames', {''}, 'TextOffset', 0, 'PlotArea', 1, 'ShowText', 0, 'TextColor', []);

if isempty(segments)
    return
end

if (nargin<1)
    help seg_plot
    return
end

if iscell(segments)
    nsegments = length(segments);
    for s = 1:nsegments
      if isempty( segments{s} )
        continue
      end
      if (~isnumeric(segments{s}) || size(segments{s},2)~=2)
        error('seg_plot:invalidSegments', 'Expecting a mx2 arrays of segment start and end times')
      end
    end
else
    nsegments=1;
    if (~isnumeric(segments) || size(segments,2)~=2)
        error('seg_plot:invalidSegments',  'Expecting a mx2 arrays of segment start and end times')
    end
end

if (nargin>1)
    try
        Args = parseArgs(varargin, Args);
    catch
        error('seg_plot:invalidArguments', 'Error parsing arguments');
    end
end

if isempty(Args.Axis)%   PlotArea:
    %hf = figure;
    Args.Axis = gca;
    if isempty(Args.XLim)
        Args.XLim = [-Inf Inf];
    end
    if isempty(Args.YOffset)
        Args.YOffset = 0;
    end
    if isempty(Args.Height)
        Args.Height=1;    
    end
elseif ~ishandle(Args.Axis)
    error('seg_plot:invalidParameter', 'Not a valid axis')
else
    yl = get(Args.Axis, 'YLim');
    if isempty(Args.YOffset)
        Args.YOffset = yl(1);
    end
    if isempty(Args.Height)
        Args.Height = yl(2)-yl(1);
    end
    if isempty(Args.XLim)
        Args.XLim = get(Args.Axis, 'XLim');    
    end
end

if iscell(segments) && isscalar(Args.YOffset)
    Args.YOffset = repmat(Args.YOffset, nsegments, 1);
elseif length(Args.YOffset)~=nsegments
    error('seg_plot:invalidParameter', 'Wrong length of YOffset parameter')
end

if iscell(segments) && isscalar(Args.Height)
    Args.Height = repmat(Args.Height, nsegments, 1);
elseif length(Args.Height)~=nsegments
    error('seg_plot:invalidParameter', 'Wrong length of Height parameter')
end

if iscell(segments) && size(Args.FaceColor,1)==1
    Args.FaceColor = repmat(Args.FaceColor, nsegments, 1);
elseif isempty(Args.FaceColor)
    Args.FaceColor = jet(nsegments);
elseif size(Args.FaceColor,1)~=nsegments
    error('seg_plot:invalidParameter', 'Wrong length of FaceColor parameter')
end

if iscell(segments) && size(Args.EdgeColor,1)==1
    Args.EdgeColor = repmat(Args.EdgeColor, nsegments, 1);
elseif size(Args.EdgeColor,1)~=nsegments
    error('seg_plot:invalidParameter', 'Wrong length of EdgeColor parameter')
end

if isempty(Args.TextColor)
    Args.TextColor = Args.EdgeColor;
elseif iscell(segments) && size(Args.TextColor,1)==1
    Args.TextColor = repmat(Args.TextColor, nsegments, 1);
elseif size(Args.TextColor,1)~=nsegments
    error('seg_plot:invalidParameter', 'Wrong length of TextColor parameter')
end

if iscell(segments) && length(Args.Alpha) == 1
    Args.Alpha = repmat(Args.Alpha, nsegments, 1);
elseif length(Args.Alpha)~=nsegments
    error('seg_plot:invalidParameter', 'Wrong length of Alpha parameter')
end

if ~isscalar(Args.TextOffset) && ~isnumeric(Args.TextOffset)
    error('seg_plot:invalidParameter', 'TextOffset parameter should be scalar')
end

if isempty(Args.SegNames)
    Args.SegNames = repmat({''}, nsegments, 1);
elseif ~iscellstr(Args.SegNames) && length(Args.SegNames)~=nsegments
    Args.SegNames = repmat({''}, nsegments, 1);
    warning('seg_plot:invalidParameter', 'Incorrect cell array of segment names')
end

axes(Args.Axis);

%axiscol = get(Args.Axis, 'Color');
if iscell(segments)
    h = {};
    if Args.PlotArea
        for c=1:nsegments

          %line( Args.XLim,  [0 0] + Args.YOffset(c)+Args.Height(c)/2, ...
          %      'Color', [0.7 0.7 0.7],'LineStyle', '- -');          
          if isempty( segments{c} )
            continue
          end
            %for s = 1:size(segments{c},1)
            id = find( segments{c}(:,2)>=Args.XLim(1) & segments{c}(:,1)<=Args.XLim(2) );
            if length(id)>0
                ptch = patch([segments{c}(id,1) segments{c}(id,1) segments{c}(id,2) segments{c}(id,2)]', ...
                repmat([Args.YOffset(c) Args.YOffset(c)+Args.Height(c) Args.YOffset(c)+Args.Height(c) Args.YOffset(c)]', ...
                1, length(id)), [0 0 0], 'FaceColor', Args.FaceColor(c,:), 'EdgeColor', Args.EdgeColor(c,:), 'HitTest', 'off');
                %alpha(ptch, Args.Alpha(c));
                %h(c) = {ptch};
                if Args.ShowText
                    text( (segments{c}(id,1) + segments{c}(id,2))/2, repmat(Args.YOffset(c)+Args.TextOffset, length(id), 1), Args.SegNames{c}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', Args.TextColor(c,:), 'BackgroundColor', 'none', 'Clipping', 'on');
                end
            end
        end
    else
        for c=1:nsegments
          %line( Args.XLim, [0 0] + Args.YOffset(c)+Args.Height(c)/2, ...
          %      'Color', [0.7 0.7 0.7],'LineStyle', '- -');          
          if isempty( segments{c} )
            continue
          end
          id = find(segments{c}(:,2)>=Args.XLim(1) & segments{c}(:,1)<=Args.XLim(2));
            if length(id)>0
                l1 = line( [segments{c}(id,1) segments{c}(id,2)]', [Args.YOffset(c) Args.YOffset(c)]' , 'Color', Args.EdgeColor(c,:), 'LineWidth', Args.LineWidth, 'LineStyle', Args.LineStyle);
                l2 = line( [segments{c}(id,1) segments{c}(id,1)]', [-Args.Height(c) Args.Height(c)]/2 + Args.YOffset(c), 'Color',  Args.EdgeColor(c,:), 'LineWidth', Args.LineWidth);
                l3 = line( [segments{c}(id,2) segments{c}(id,2)]', [-Args.Height(c) Args.Height(c)]/2 + Args.YOffset(c), 'Color',  Args.EdgeColor(c,:), 'LineWidth', Args.LineWidth);
                h(c) = {[l1(:) l2(:) l3(:)]};
                if Args.ShowText
                    text( (segments{c}(id,1) + segments{c}(id,2))/2, repmat(Args.YOffset(c)+Args.TextOffset, length(id), 1), Args.SegNames{c}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', Args.TextColor(c,:), 'BackgroundColor', 'none', 'Clipping', 'on');
                end
            end
        end
    end
else
    %for s = 1:size(segments,1)
    if Args.PlotArea
        id = find(segments(:,2)>=Args.XLim(1) & segments(:,1)<=Args.XLim(2));
        if length(id)>0
            h = patch([segments(id,1) segments(id,1) segments(id,2) segments(id,2)]', repmat([Args.YOffset Args.YOffset+Args.Height Args.YOffset+Args.Height Args.YOffset]', 1, length(id)), [0 0 0], 'FaceColor', Args.FaceColor, 'EdgeColor', Args.EdgeColor, 'HitTest', 'off');
            alpha(h, Args.Alpha);
        end
    else
        id = find(segments(:,2)>=Args.XLim(1) & segments(:,1)<=Args.XLim(2));
        if length(id)>0
          l1 = line( [segments(id,1) segments(id,2)]', [Args.YOffset Args.YOffset]' , 'Color', Args.EdgeColor, 'LineWidth', Args.LineWidth, 'LineStyle', Args.LineStyle);
          l2 = line( [segments(id,1) segments(id,1)]', [-Args.Height Args.Height]/2 + Args.YOffset, 'Color',  Args.EdgeColor, 'LineWidth', Args.LineWidth);
          l3 = line( [segments(id,2) segments(id,2)]', [-Args.Height Args.Height]/2 + Args.YOffset, 'Color',  Args.EdgeColor, 'LineWidth', Args.LineWidth);
          h = [l1(:) l2(:) l3(:)];
        end
    end
    %end
end
