function h=arrowhead(xy,varargin)
%ARROWHEAD draw arrowheads
%
%  h=ARROWHEAD(xy) where xy is a nx2 matrix of coordinates defining a
%  polyline, this function will draw a black filled arrowhead at the
%  center of each line segment, pointing from the first point to the
%  second point of the line segment. The function returns a handle to a
%  patch object.
%
%  h=ARROWHEAD(xy,angle) where xy is a nx2 matrix defining a set of
%  coordinates and angle is a length n vector of angles (in radians),
%  this function will draw an arrowhead at each point with the specified
%  angle.
%
%  h=ARROWHEAD(...,param,value,...) Additional parameter/value
%  pairs. Valid options are:
%   color - set arrowhead color, can be any of
%           'r','g','b','c','m','y','k', or a vector with for each
%           arrowhead an index into the current colormap, or a single [r
%           g b] vector or a [r g b] matrix that specifies a color for
%           each arrowhead. 
%   alpha - set arrowhead transparency, can be a scalar (0-1) or a vector
%           that specifies an alpha value for each arrowhead.
%   scale - set arrowhead size, can be a scalar or a two-element vector
%           that specifies the scaling for width and length
%           separately. Can also be a length n vector or nx2 matrix the
%           specify the scaling for each arrowhead separately.
%   refpoint - reference (zero) point in template coordinates
%   offset - offset in world coordinates (i.e. after scaling)
%   axis - parent axes handle
%   template - 2-by-n matrix specifying x and y coordinates for the shape
%              of the arrow. Coordinates are scaled to fit within a
%              2-by-2 box around zero.
%  In addition to the options listed above, all options that the patch
%  function accepts are allowed as well.
%

%check arguments and options
options = struct('color', 'k', ...
                 'alpha', 1, ...
                 'scale', 1, ...
                 'refpoint', [0 0], ...
                 'offset', [0 0], ...
                 'axis', [], ...
                 'template', [-0.5 -0.5; 0 0.5; 0.5 -0.5]');

[options, other, remainder] = parseArgs( varargin, options );

if ndims(xy)>2 || size(xy,2)~=2
  error('arrowhead:invalidArgument', 'invalid argument');
end

npoints = size(xy,1);

if ~isempty(other)
  d = other{1};
  
  if isempty(d)
    d = atan2( diff(xy(:,2)), diff(xy(:,1)) ) - 0.5*pi;
    xy = (xy(1:end-1,:) + xy(2:end,:) )/2;
    npoints = size(xy,1);
  elseif ~isvector(d) || numel(d)~=npoints
    error('arrowhead:invalidArgument', 'invalid argument');
  end
  
elseif npoints==1
  error('arrowhead:invalidArgument', 'invalid argument');
else
  d = atan2( diff(xy(:,2)), diff(xy(:,1)) ) - 0.5*pi;
  xy = (xy(1:end-1,:) + xy(2:end,:) )/2;
  npoints = size(xy,1);
end

if ~isnumeric(options.template) || ndims(options.template)>2 || ...
      size(options.template,1)~=2 || size(options.template,2)<2
  error('arrowhead:invalidArgument', 'invalid argument');
else
  options.template = normalize( options.template, 0, 'max' );
end

if isempty(options.axis)
  options.axis = gca;
elseif ~ishandle(options.axis) || ~strcmp(get(options.axis,'Type'), 'axes')
  error('arrowhead:invalidArgument', 'invalid argument');
end

if isnumeric(options.color) && isvector(options.color) && ~isequal(size(options.color), [1 3] ) && ...
      numel(options.color)==npoints 
  tmp = get( gcf, 'colormap' );
  options.color = permute( tmp(options.color ,:), [3 1 2] );
elseif (ischar(options.color) && ~ismember(options.color,{'r','g','b','c','m','y','k'}))
  error('arrowhead:invalidArgument', 'invalid argument'); 
elseif isnumeric(options.color) && (ndims(options.color)>2 || size(options.color,2)~=3 || ...
      (size(options.color,1)~=1 && size(options.color,1)~=npoints))
  error('arrowhead:invalidArgument', 'invalid argument');  
else
  options.color = permute(options.color, [3 1 2]);
end

if ~isnumeric(options.alpha) || ~isvector(options.alpha) || ...
      (numel(options.alpha)~=1 && numel(options.alpha)~=npoints)
  error('arrowhead:invalidArgument', 'invalid argument');  
end

if isscalar(options.scale) || (isvector(options.scale) && numel(options.scale)==npoints)
  options.scale = [options.scale(:) options.scale(:)];
elseif ~isnumeric(options.scale) || ndims(options.scale)~=2 || ...
      size(options.scale,2)~=2 || (size(options.scale,1)~=1 && size(options.scale,1)~=npoints)
  error('arrowhead:invalidArgument', 'invalid argument');   
end  

%compute coordinates
x = bsxfun(@times, options.scale(:,1), options.template(1,:) - options.refpoint(1) ) - options.offset(1);
y = bsxfun(@times, options.scale(:,end), options.template(2,:) - options.refpoint(2) ) - options.offset(2);

cosd = cos(d(:));
sind = sin(d(:));

xx = bsxfun(@plus, xy(:,1), bsxfun(@times, x, cosd ) - bsxfun(@times, y, sind ) );
yy = bsxfun(@plus, xy(:,2), bsxfun(@times, x, sind ) + bsxfun(@times, y, cosd ) );


%draw arrowheads
h = patch( xx', yy', options.color, 'FaceVertexAlphaData', options.alpha(:), ...
           'FaceAlpha', 'flat', remainder{:}, 'Parent', options.axis);
