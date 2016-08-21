function L=layoutmanager(varargin)
%LAYOUTMANAGER layoutmanager constructor
%
%  l=LAYOUTMANAGER default constructor, create empty layout manager
%  object.
%
%  l=LAYOUTMANAGER(l) copy constructor
%
%  l=LAYOUTMANAGER(h) creates a new layout manager object with a single
%  axes in the figure or uipanel with handle h. Or, if the object with
%  handle h already contains a layout manager, it will return that
%  object.
%
%  l=LAYOUTMANAGER(h,r,c) creates a new layout manager object with rxc
%  axes in the container with handle h.
%
%  l=LAYOUTMANAGER(h,r,c,parm1,val1,...) set optional parameters. Valid
%  parameters are:
%   xoffset - horizontal distance between container and its children
%   yoffset - vertical distance between container and its children
%   xspacing - horizontal spacing between children
%   yspacing - vertical spacing between children
%   fcn - creation function, eg @axes or @uipanel (default = @axes).
%   argin - cell array with extra arguments for the creation function.
%   width - scalar or vector with the relative widths for all columns.
%   height - scalar or vector with the relative heights for all rows.
%   z - number of levels, i.e. how many overlapping children at each
%       row/column intersection.
%   units - units (default = characters)
%

if nargin<1
  L = struct('parent', [], ...
             'childmatrix', []);
  L = class(L, 'layoutmanager');
elseif nargin==1 && isa(varargin{1},'layoutmanager')
  L = varargin{1};
else
  
  h = varargin{1};
  if ~ishandle(h) || ~ismember(get(h,'Type'), {'figure', 'uipanel'})
    error('layoutmanager:layoutmanager:invalidHandle', 'Invalid handle')
  end
  
  Lappdata = getappdata(h, 'LayoutManager');
  
  if isempty(Lappdata)
    %setup new manager
    Lappdata = struct('xoffset', 0, ...
                      'yoffset', 0, ...
                      'xspacing', 0, ...
                      'yspacing', 0, ...
                      'fcn', @axes, ...
                      'argin', {{}}, ...
                      'width', 1, ...
                      'height', 1, ...
                      'z', 1, ...
                      'units', 'characters');
    %parse arguments
    if nargin<2 || isempty(varargin{2})
      nrows = 1;
    else
      nrows = varargin{2};
      Lappdata.height = ones(nrows,1);
    end
    if nargin<3 || isempty(varargin{3})
      ncols = 1;
    else
      ncols = varargin{3};
      Lappdata.width = ones(1,ncols);
    end
    
    L.parent = h;
    Lappdata.childmatrix = NaN(nrows, ncols);
    
    valid_parms = {'xoffset', 'xspacing', 'yoffset', 'yspacing', 'width', ...
                'height', 'fcn', 'argin', 'units', 'z'};
    
    Lappdata = validate_parms(Lappdata, valid_parms, varargin{4:end});

    for r=1:nrows
      for c=1:ncols
        for level = 1:Lappdata.z
          Lappdata.childmatrix(r,c,level) = Lappdata.fcn( Lappdata.argin{:}, 'Parent', L.parent );
        end
      end
    end
    
    setappdata(L.parent, 'LayoutManager', Lappdata);  
    
    resizefcn( L.parent, []);
    set(L.parent, 'ResizeFcn', @resizefcn);
    
    L = class(L, 'layoutmanager');
  
  else
    L = class(struct('parent', h), 'layoutmanager');
    %change existing manager
    set(L, varargin{2:end});
  end 
  
end