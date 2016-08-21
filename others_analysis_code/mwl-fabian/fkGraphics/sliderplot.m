function [ha hs] = sliderplot( varargin )
%SLIDERPLOT simple plot with slider
%
%  [hax,hs]=SLIDERPLOT(...) simple single axis plot with a slider to
%  browse through the data. The function returns the handle of the axes
%  and the slider object. Arguments can be anything that the plot command
%  accepts.
%
%  [hax,hs]=SLIDERPLOT({...},{...},...) plots multiple plots in multiple
%  axes. Every argument should be a cell array with valid arguments for
%  the plot command.
%
%  [hax,hs]=SLIDERPLOT({...},{...},...,'height',h) sets the relative
%  heights of the multiple axes.
%

%create figure and uipanels
hf = figure('MenuBar', 'none', 'ToolBar', 'none');
hp = layoutmanager(hf, 2,1, 'Fcn', @uipanel, ...
                       'ArgIn', {'BorderType', 'none'}, 'YOffset', 0, 'XOffset', 0, 'YSpacing', 0, 'XSpacing', 0, ...
                       'Width', 1, 'Height', [1 -2]);

if nargin>0 && iscell(varargin{1})
  options = struct('height',1);
  [options,other] = parseArgs( varargin, options);
  if isempty(other)
    error('sliderplot:invalidArguments', 'nothing to plot')
  end
  nplots = numel(other);
  L=layoutmanager(hp(1),nplots,1,'XOffset', 6, 'YSpacing', 1, 'YOffset', ...
                  2, 'Height', options.height);
  
  for k=1:nplots
    plot(other{k}{:}, 'Parent', L(k,1) );
  end

  ha = L.childmatrix;
  
  set(ha(1:(end-1)), 'XTick', [] );
  
else
  %create axes and plot
  ha = axes( 'Parent', hp(1) );
  if nargin>0
    plot( ha, varargin{:});
  end
end
  

%get limits
xl = get( ha, 'XLim');

if iscell(xl)
  xl = vertcat(xl{:});
  xl = [min(xl(:,1)) max(xl(:,2))];
end

%create slider
hs = slider( hp(2), 'limits', xl );

%link slider and axes
linkaxes( hs, ha);

%set viewport to 10% of limits
set(hs, 'center', xl(1) + 0.5*diff(xl)./10, 'windowsize', diff(xl)./10 );

%enable scrolling and panning
scroll_zoom( ha, 'factor', 1.2, 'axis', 'xy', 'modifier', 1 );
scroll_pan( ha, 'modifier', 2);
