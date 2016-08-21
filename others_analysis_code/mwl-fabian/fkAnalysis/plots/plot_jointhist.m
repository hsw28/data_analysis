function plot_jointhist( m, varargin )
%PLOT_JOINTHIST plot joint histogram and marginals
%
%  PLOT_JOINTHIST(h) plot the 2d histogram h and its marginals in a new
%  figure;
%
%  PLOT_JOINTHIST(h,param,val,...) specify additional options as
%  parameter/value pairs. Valid parameters are:
%   label - label for the z-axis
%   title - title for the plot
%   xlabel - label for the x-axis (rows)
%   ylabel - label for the y-axis (columns)
%   xbins - x-axis bin edges or bin centers
%   ybins - y-axis bin edges or bin centers
%   weights - matrix the same size as h which specifies weights for each
%             observation such that the marginals can be correctly
%             computed
%   parent - handle of parent figure or panel
%


if nargin<1
  help(mfilename)
  return
end

if ~isnumeric(m) || ndims(m)>2
  error('plot_jointhist:invalidArgument', 'Invalid argument')
end

options = struct( 'label', '', 'title', '', 'xlabel', '', 'ylabel', '', ...
                  'xbins', [], 'ybins', [], 'weights', [], 'parent', [] );

options = parseArgs(varargin,options);

if isempty(options.parent)
  h = figure;
else
  h = options.parent;
end

hAx = layoutmanager(h, 2, 2, 'yspacing', 1, 'xspacing', 2, 'xoffset', ...
                    9, 'yoffset', 3, 'width', [1 3], 'height', [3 1] );

if isempty(options.xbins)
  xbins = 1:size(m,1);
  xlimits = xbins([1 end]) + [-0.5 0.5];
elseif numel(options.xbins)==size(m,1)+1
  xbins = ( options.xbins(1:end-1) + options.xbins(2:end) )/2;
  xlimits = options.xbins([1 end] );
elseif numel(options.xbins)==size(m,1)
  xbins = options.xbins(:);
  xlimits = xbins([1 end]) + [-0.5 0.5].*( diff( xbins([1 end] ) + 1 ) ./ numel(xbins));
else
  error('plot_jointhist:invalidArgument', 'Invalid argument')
end

if isempty(options.ybins)
  ybins = 1:size(m,2);
  ylimits = ybins([1 end]) + [-0.5 0.5];
elseif numel(options.ybins)==size(m,2)+1
  ybins = ( options.ybins(1:end-1) + options.ybins(2:end) )/2;
  ylimits = options.ybins([1 end] );
elseif numel(options.ybins)==size(m,2)
  ybins = options.ybins(:);
  ylimits = ybins([1 end]) + [-0.5 0.5].*( diff( ybins([1 end] ) + 1 ) ./ numel(ybins));
else
  error('plot_jointhist:invalidArgument', 'Invalid argument')
end

imagesc( xbins, ybins, m', 'parent', hAx(1,2) );

if isempty(options.weights)
  
  bar( hAx(2,2), xbins, sum( m, 2 ), 1 );
  barh( hAx(1,1), ybins, sum( m ), 1 );
  
else
  
  mw = options.weights .* m;
  
  bar( hAx(2,2), xbins, nansum( mw, 2 ) ./ nansum(options.weights,2), 1 );
  barh( hAx(1,1), ybins, nansum( mw ) ./ nansum(options.weights), 1 );  
  
end

     
hC = colorbar('peer', hAx(1,2));  
xlabel( hAx(2,2), options.xlabel);
ylabel( hAx(1,1), options.ylabel);
ylabel( hC, options.label );  
  
set( hAx(1,1:2), 'ylim', ylimits, 'ydir', 'normal')
set( hAx(1:2,2), 'xlim', xlimits );
set( hAx(1,2), 'XTick', [], 'YTick', [] );
set( hAx(1,1), 'XAxisLocation', 'top' );
set( hAx(2,2), 'YAxisLocation', 'right');
  
xlabel( hAx(1,1), options.label);
ylabel( hAx(2,2), options.label);
  
title( hAx(1,2), options.title, 'fontsize', 12);

delete( hAx(2,1) );
  
return  
  
