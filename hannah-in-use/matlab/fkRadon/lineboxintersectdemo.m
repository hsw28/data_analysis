function lineboxintersectdemo( varargin )
%LINEBOXINTERSECTDEMO demonstrates lineboxintersect function
%
%  LINEBOXINTERSECTDEMO plots a 1x1 box in the upper plot and theta-rho
%  space in the lower plot. By clicking in the lower plot, the line
%  defined by the theta, rho pair at that point is drawn in the upper
%  plot.
%
%  LINEBOXINTERSECTDEMO(box) specify your own box in [xleft xright
%  ybottom ytop] format.
%
%  LINEBOXINTERSECTDEMO(box,theta) specify the theta range (default=[-0.5
%  0.5]*pi)
%
%  LINEBOXINTERSECTDEMO(box,theta,rho) specify the rho range.
%

B = [0 1 0 1];
if nargin>0
  if ~isempty(varargin{1}) && isequal(size(varargin{1}),[1 4])
    B = varargin{1};
  else
    error('lineboxintersectdemo:invalidArguments', 'Incorrect box specification');
  end
end

Bcenter = (B([1 3])+B([2 4]))/2;
B = B - Bcenter([1 1 2 2]);

theta_range = [-0.5 0.5]*pi;
if nargin>1
  if ~isempty(varargin{2}) && isequal(size(varargin{2}), [1 2])
    theta_range = sort( mod( mod( theta_range, 2*pi)+2*pi,2*pi));
  else
    error('lineboxintersectdemo:invalidArguments', 'Incorrect theta range')
  end
end

if nargin>2
  if ~isempty(varargin{3}) && isequal(size(varargin{3}),[1 2])
    rho_range = sort( varargin{3} );
  else
    error('lineboxintersectdemo:invalidArguments', 'Incorrect rho range')
  end
else
  rho_range = [-1 1].*sqrt(B(1).^2+B(3).^2);
end    
  
hFig = figure;

try
  event_dispatch(hFig);
catch
  error('lineboxintersectdemo:missRequirement', ['Event dispatching toolbox ' ...
                      'is required']);
end

hAx1 = subplot(2,1,1);
rectangle('Position', [B(1) B(3) B(2)-B(1) B(4)-B(3)] + [Bcenter([1 2]) 0 0], 'Parent', hAx1 );

set( hAx1, 'XLim', 1.25.*B([1 2]) + Bcenter(1), ...
           'YLim', 1.25.*B([3 4]) + Bcenter(2));

hAx2 = subplot(2,1,2);
set(hAx2, 'XLim', rho_range, 'YLim', theta_range);
xlabel('rho');
ylabel('theta');

enable_events( hAx2 );

L = line(NaN,NaN,'Parent', hAx1, 'Visible', 'off', 'Color', [1 0 0] );

add_callback(hAx2, 'MyButtonDownFcn', {@intersectline});
add_callback(hAx2, 'MyDragFcn', {@intersectline});
add_callback(hAx2, 'MyButtonUpFcn', @(h,e) set(L, 'Visible', 'off') );

  function intersectline( hObj, eventdata) %#ok
  
  theta = eventdata.HitPoint(2);
  rho = eventdata.HitPoint(1);
  
  [px, py] = lineboxintersect( [theta rho], B );
  
  set( L, 'XData', px+Bcenter(1), 'YData', py+Bcenter(2), 'Visible', 'on' )
  
  end

end
