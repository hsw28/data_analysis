function S=slider(varargin)
%SLIDER slider object constructor
%
%  s=SLIDER default constructor, creates an empty slider object
%
%  s=SLIDER(s) copy constructor
%
%  s=SLIDER(h) create slider in container with handle h.
%
%  s=SLIDER(h,parm1,val1,...) set optional parameters. Valid parameters
%  are: limits, center, windowsize, updatemode, color
%


if nargin<1
  
  S = struct( 'parent', [] );
  S = class( S, 'slider' );
  
elseif nargin==1 && isa(varargin{1}, 'slider')
  S = varargin{1};
  
else
  
  h = varargin{1};
  if ~ishandle(h) || ~ismember(get(h,'Type'), {'figure', 'uipanel'})
    error('slider:slider:invalidHandle', 'Invalid container handle')
  end
  
  Sappdata = getappdata(h, 'Slider');
  
  if isempty(Sappdata)
    %setup new slider
    Sappdata = struct('ui', [], ...
                      'limits', [0 1], ...
                      'center', 0.5, ...
                      'windowsize', 0.1, ...
                      'updatefcn', struct('id', {}, 'fcn', {}), ...
                      'updatemode', 'delayed', ...
                      'displaymode', 'strict', ...
                      'linkedaxes', struct('axes', {}, 'listeners', {}), ...
                      'markers', struct(), ...
                      'color', [0.6 0.6 1], ...
                      'currentmarker', 'none', ...
                      'currentmarkerval', NaN, ...
                      'suspend_callback', 0);
    
    valid_parms = {'limits', 'center', 'windowsize', ...
                   'updatemode', 'color', 'displaymode'};
                   
    Sappdata = validate_parms(Sappdata, valid_parms, varargin{2:end});
    
    S.parent = h;
    
    Sappdata.ui = drawslider( h, Sappdata );
    
    setappdata( S.parent, 'Slider', Sappdata );
    
    S = class( S, 'slider' );
    
  else
    
    S = class( struct('parent', h), 'slider' );
    
    set(S, varargin{2:end});
    
  end
  
end

