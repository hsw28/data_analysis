function [h, fig] = axismatrix(nrows, ncolumns, varargin)
%AXISMATRIX create a matrix of axes
%
%  Syntax
%
%      h = axismatrix( nrows, ncolumns [, mask, ...] )
%
%  Description
%
%    Create a nrows x ncolumns matrix of axes in a figure. Optionally you
%    can specify a binary mask that specifies in which location axes
%    should be created. If mask is a scalar than it indicates the number
%    of axes to create (in row order, starting from the top left).
%
%  Options
%
%      Parent = parent figure or other ui container (default = new figure)
%      XOffset,YOffset = size of border between axes and parent (default = 0)
%      XSpacing, YSpacing = size of spacing between axes (default = 0)
%      Fcn = ui object create function (default = @axes). The function
%            should accept 'Parent', 'Position' and 'Units' options, for
%            example @uipanel. 
%      ArgIn = cell array of additional arguments to ui object create
%              function.
%      RowsPerPage = number of rows in a single figure. If nrows >
%                    RowsPerPage than multiple figures (pages) are
%                    created. (default = nrows )
%      Width = widths of axes. Can be either scalar or a ncolumns-length
%              vector. Positive widths are variable (relative to container)
%              and negative widths are fixed. 
%      Height = height of axes. Can be either a scalar or a RowsPerPage-length
%               vector. Positive heights are variable (relative to
%               container) and negative heights are fixed.
%      Units = units of measurement (default = 'characters')
%
%  Dependencies
%
%    parseArgs, resizefcn
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1 || isempty(nrows)
    nrows = 1;
end
if nargin<2 || isempty(ncolumns)
    ncolumns = 1;
end

%parse options
args = struct('Parent', [], 'XOffset', 0, 'XSpacing', 0, 'YOffset', ...
              0, 'YSpacing', 0, 'Fcn', @axes, ...
              'ArgIn', {{}}, 'Width', 1, 'Height', 1, 'RowsPerPage', nrows, 'Units', 'characters');

%create mask
if nargin>2 && isnumeric(varargin{1})
    if isscalar(varargin{1})
        mask = zeros(nrows, ncolumns)';
        mask(1:varargin{1}) = 1;
        mask = mask';
    elseif ndims(varargin{1} == 2) && all( size( varargin{1} ) == [nrows ncolumns] )
        mask = varargin{1};
    else
        error('Invalid mask')
    end
    args = parseArgs(varargin(2:end), args);
else
    mask = ones(nrows, ncolumns );
    args = parseArgs(varargin, args);    
end

%calculate number of pages
npages = ceil( nrows ./ args.RowsPerPage );

h = NaN(nrows, ncolumns);
fig = NaN(npages,1);

%create parent if needed
if isempty(args.Parent)
    for k=1:npages
        fig(k) = figure;
    end
elseif npages==1
    fig = args.Parent;
else
    error('fkUtilities:axismatrix:noMultiPage', ['Multiple pages not allowed ' ...
                        'if parent is given'])
end

%check height parameter
if isscalar(args.Height)
    args.Height = ones( args.RowsPerPage, 1).*args.Height;
elseif numel(args.Height) ~= args.RowsPerPage
    error( 'fkUtilities:axismatrix:invalidHeight', 'Incorrect size of Height option' )
else
    args.Height = args.Height;
end

%create pages
for p = 1:npages
  
  %compute row offsets
  row_offset = args.RowsPerPage.*(p-1);
  rows = (1:max(args.RowsPerPage, nrows-row_offset))+row_offset;
  
  for r = rows
    
    for c = 1:ncolumns
      
      if mask(r,c)
        %create ui object
        h(r,c) = args.Fcn( args.ArgIn{:}, 'Parent', fig(p) );
        
      end
      
    end
    
  end
  
  %set proper size of all ui objects and set parent resizefcn
  resizefcn( fig(p), [], h(rows,:), args.Height, args.Width, args.YOffset, args.YSpacing, args.XOffset, ...
                   args.XSpacing, args.Units );
  set(fig(p), 'ResizeFcn', {@resizefcn, h(rows,:), args.Height, ...
                      args.Width, args.YOffset, args.YSpacing, args.XOffset, ...
                   args.XSpacing, args.Units});
  
end
