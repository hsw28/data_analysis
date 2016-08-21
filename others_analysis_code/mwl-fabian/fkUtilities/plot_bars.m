function h = plot_bars( y, varargin)
%PLOT_BARS create bar plot
%
%  h=PLOT_BARS(y) draw bar plot of data in vector y and returns the
%  handle to the patches that make up the bars.
%
%  h=PLOT_BARS(y,parm1,val1,...) sets additional parameters. Valid
%  parameters are:
%   Parent - parent axes, figure or uipanel
%   FaceColor - bar color
%   EdgeColor - bar line color
%   Edges - edges of bars (should have a lenght of length(y)+1, default =
%           (0:numel(y))
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
  help(mfilename)
  return
end

%parse options
args = struct('Parent', [], 'FaceColor', [0 0 0], 'EdgeColor', [1 1 1], 'Edges', []);
args = parseArgs( varargin, args );

%create parent
if isempty(args.Parent)
    ax = gca;    
elseif ishandle(args.Parent) && strcmp( get(args.Parent, 'Type'), 'axes')
    ax = args.Parent;
elseif ishandle(args.Parent) && ismember( get(args.Parent, 'Type'), {'figure', 'uipanel'} )
    ax = axes('Parent', args.Parent);
else
    error('plot_bars:invalidPArent', 'Invalid parent')
end

%create default edges
if isempty(args.Edges)
    args.Edges = [ (0:numel(y))' (1:numel(y)+1)'];
elseif isvector(args.Edges) && numel(y)==numel(args.Edges)-1
    args.Edges = args.Edges(:);
    args.Edges = [ args.Edges(1:end-1) args.Edges(2:end)];
elseif ~isequal(size(args.Edges), [numel(y), 2] )
    error('plot_bars:invalidData', 'Sizes of data and edges do not match')
end

% if numel(y)~=numel(args.Edges)-1
%     error('plot_bars:invalidData', 'Sizes of data and edges do not match')
% end

%make axis current
axes(ax);

%draw patches
%h = patch( [args.Edges(1:end-1) ; args.Edges(2:end) ; args.Edges(2:end) ; args.Edges(1:end-1)], [zeros(2,numel(y)) ; y(:)' ; y(:)'], args.FaceColor, 'EdgeColor', args.EdgeColor );
h = patch( [args.Edges(:,1) args.Edges(:,2) args.Edges(:,2) args.Edges(:,1)]', [zeros(2,numel(y)) ; y(:)' ; y(:)'], args.FaceColor, 'EdgeColor', args.EdgeColor );