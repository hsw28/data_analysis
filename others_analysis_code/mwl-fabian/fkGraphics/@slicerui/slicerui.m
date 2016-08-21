function SUI = slicerui(varargin)
%SLICERUI slicer ui constructor
%
%  slicer=SLICERUI default constructor, create empty slicer ui object.
%
%  slicer=SLICERUI(slicer) copy constructor
%
%  slicer=SLICERUI(grid) create new slicer ui object and set the initial
%  grid.
%
%  slicer=SLICERUI(grid,state) sets the initial state.
%

SUI = struct('hash', []);

s = struct( 'ui', struct(), 'grid', [], 'callbacks', struct('id', {}, ...
                                                  'fcn', {}), 'state', ...
            struct(), 'suspend_callback', 0, 'comboboxchange', 0 );

if nargin<1
  
  SUI = class( SUI, 'slicerui' );
  
elseif nargin==1 && isa(varargin{1}, 'slicerui')
  
  SUI = varargin{1};
  
else
  
  if ~isa(varargin{1}, 'fkgrid') || ndims(varargin{1})<2
    error('slicerui:invalidInput', 'Invalid fkgrid')
  end
  
  s.grid = varargin{1};
  
  if nargin<2
    s.state = default_state( s.grid );
  else
    s.state = validate_state( s.grid, varargin{2} );
  end
  
  SUI.hash = mhashtable;

  s.ui = create_slicerui( s.grid, s.state, SUI.hash.hashcode);
  
  SUI.hash.put('slicer', s);
  
  SUI = class( SUI, 'slicerui' );
  
end
