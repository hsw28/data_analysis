function radondemo(M, method)
%RADONDEMO demonstrates the radon transform
%
%  RADONDEMO computes and shows the radon transform of an image and lets
%  the user explore the transformation between image-space and
%  radon-space.
%
%  RADONDEMO(img) uses the given image.
%
%  RADONDEMO(img,method) specifies custom method. Valid values are:
%  integral, sum, mean, product, logsum (default='sum')
%

%  Copyright 2007-2008 Fabian Kloosterman

interpolation = 'linear';
dtheta = 0.01;
drho = 2;

if nargin<2 || isempty(method)
  method = 'sum';
end

if nargin<1 || isempty(M)
  M = imread('eight.tif');
end

M = double(M);

hFig = figure;
colormap gray;
event_dispatch(hFig);

hSource = subplot(3,1,1);
enable_events( hSource );

imagesc( M );
xlabel('X');
ylabel('Y');
title('Source image');

%radon transform
[r, nn, settings] = radon_transform( M', 'interp', interpolation, ...
                                     'method', method, 'dtheta', dtheta, ...
                                     'drho', drho); %#ok


hAx = subplot(3,1,2);
enable_events( hAx );

img1 = imagesc( settings.rho, settings.theta, r );
xlabel('rho');
ylabel('theta');
title('Radon transform');

rl1 = line( 0,0,'Parent',hSource,'Visible','off','Color',[1 0 0]);
rl1b = line( 0,0,'Parent',hSource,'Visible','off','Color',[0 0 1],'LineStyle','none','Marker','o');

pl1 = line( 0,0,'Parent',hAx,'Visible','off','Color',[1 0 0]);

txt1 = text( 0,0,'','Parent',hAx,'Visible','off','Color',[1 0 0]);

add_callback(hAx, 'MyButtonDownFcn', {@radonline, settings});
add_callback(hAx, 'MyDragFcn', {@radonline, settings});
add_callback(hAx, 'MyButtonUpFcn', @(h,e) set([rl1 rl1b txt1], 'Visible', 'off') );


%radon transform (rho_x = true)
[r, nn, settings] = radon_transform( M', 'interp', interpolation, ...
                                     'rho_x', 1, 'method',method, 'dtheta', ...
                                     dtheta, 'drho', drho); %#ok

hAx = subplot(3,1,3);
enable_events( hAx );

img2 = imagesc( settings.rho, settings.theta, r );
xlabel('rho_x');
ylabel('theta');
title('Radon transform II');

rl2 = line( 0,0,'Parent',hSource,'Visible','off','Color',[1 0 0]);
rl2b = line( 0,0,'Parent',hSource,'Visible','off','Color',[0 0 1],'LineStyle','none','Marker','o');

pl2 = line( 0,0,'Parent',hAx,'Visible','off','Color',[1 0 0]);

txt2 = text( 0,0,'','Parent',hAx,'Visible','off','Color',[1 0 0]);

add_callback(hAx, 'MyButtonDownFcn', {@radonline2, settings});
add_callback(hAx, 'MyDragFcn', {@radonline2, settings});
add_callback(hAx, 'MyButtonUpFcn', @(h,e) set([rl2 rl2b txt2], 'Visible', 'off') );

add_callback(hSource, 'MyButtonDownFcn', {@radonpixel, settings});
add_callback(hSource, 'MyDragFcn', {@radonpixel, settings});
add_callback(hSource, 'MyButtonUpFcn', @(h,e) set([pl1 pl2], 'Visible', ...
                                                             'off') );

  function radonpixel( hObj, eventdata, s) %#ok
  
  x = eventdata.HitPoint(1);
  y = eventdata.HitPoint(2);
  
  x = x + s.xmin - 1;
  y = y + s.ymin - 1;
  
  rho = x.*cos( s.theta ) + y.*sin( s.theta );
  
  set( pl1, 'XData', rho, 'YData', s.theta, 'Visible', 'on' );
  set( pl2, 'XData', rho./cos(s.theta), 'YData', s.theta, 'Visible', 'on' );  
  
  end


  function radonline( hObj, eventdata, s ) %#ok
  
  rho = eventdata.HitPoint(1);
  theta = eventdata.HitPoint(2);
  
  [px, py] = lineboxintersect( [theta rho], [s.xmin -s.xmin s.ymin -s.ymin] );
  
  cdata = get(img1, 'CData');
  xl = get(img1, 'XData');
  yl = get(img1, 'YData');
  xl = interp1( xl, 1:numel(xl), rho, 'nearest' );
  yl = interp1( yl, 1:numel(yl), theta, 'nearest' );
  
  set( rl1, 'XData', px - s.xmin + 1, 'YData', py - s.ymin + 1, 'Visible', 'on');
  if ~isempty(px)
    set( rl1b, 'XData', px(1) - s.xmin + 1, 'YData', py(1) - s.ymin + 1, 'Visible', 'on');
  end
  
  try  
    set( txt1, 'Position', [rho theta 0], ...
               'String', num2str( cdata( yl, xl ) ), ...
               'Visible', 'on');
  catch
    set(txt1, 'Visible', 'off');
  end
  
  end

  function radonline2( hObj, eventdata, s ) %#ok
  
  theta = eventdata.HitPoint(2);
  rho = eventdata.HitPoint(1);

  [px, py] = lineboxintersect( [theta rho .* cos(theta)], [s.xmin -s.xmin s.ymin -s.ymin] );

  cdata = get(img2, 'CData');
  xl = get(img2, 'XData');
  yl = get(img2, 'YData');
  xl = interp1( xl, 1:numel(xl), rho, 'nearest' );
  yl = interp1( yl, 1:numel(yl), theta, 'nearest' );
  
  set( rl2, 'XData', px - s.xmin + 1, 'YData', py - s.ymin + 1, 'Visible', 'on');
  if ~isempty(px)
    set( rl2b, 'XData', px(1) - s.xmin + 1, 'YData', py(1) - s.ymin + 1, 'Visible', 'on' );
  end
  
  try
    set( txt2, 'Position', [rho theta 0], ...
               'String', num2str( cdata( yl, xl ) ), ...
               'Visible', 'on');    
  catch
    set( txt2, 'Visible', 'off')
  end
  
  end

end

