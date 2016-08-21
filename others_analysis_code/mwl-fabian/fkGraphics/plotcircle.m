function h = plotcircle(center, radius, varargin)
%PLOTCIRCLE plot a circle
%
%  h=PLOTCIRCLE(center,radius) plots a circle defined by the center and
%  radius and returns a handle.
%
%  h=PLOTCIRCLE(...,arg1,arg2,...) passes extra arguments to the
%  rectangle function that is used to plot the circle.
%

if nargin<2
  help(mfilename)
  return
end

if ~isnumeric(center) || numel(center)~=2
  error('plotcircle:invalidArgument', 'Invalid center')
end

if ~isnumeric(radius) || ~isscalar(radius) || radius<=0
  error('plotcircle:invalidArgument', 'Invalid radius')
end

p = [center(1)-radius center(2)-radius 2*radius 2*radius];
h = rectangle( varargin{:}, 'Position', p, 'Curvature', [1 1] );
