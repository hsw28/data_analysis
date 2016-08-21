function refresh(h)
%REFRESH refresh function for polar cursor
%
%  REFRESH(h) redraw polar cursor object
%

%  Copyright 2008-2008 Fabian Kloosterman


%do nothing if we're clean
if ~strcmp(h.Dirty,'clean')
  
  %get angles in radians
  anglelim = fkGraphics.getradians(h, 'AngleLim');
  snapangle = fkGraphics.getradians(h, 'SnapAngle');
  
  %get parent axes
  parent = ancestor(double(h),{'axes'});
  
  if isa( handle(parent), 'fkGraphics.polaraxes') %polar axes
      
    %get polar axes onbect
    parent = handle(parent);
    
    %apply snapping
    if snapangle~=0
      theta = round( anglelim./snapangle ) .* snapangle;
    else
      theta = anglelim;
    end
      
    %get axes limits in radians
    axlim = limit2pi( fkGraphics.getradians(parent, 'AngleLim') );
    
    %clip cursor angles to axes limits
    if axlim(1)~=axlim(2)
      
      if axlim(1)>axlim(2)
        inlim = theta>=axlim(1) | theta<=axlim(2);
      else
        inlim = theta>=axlim(1) & theta<=axlim(2);
      end
      
      if all(inlim==1)
        tmp = limit2pi(theta - axlim(1));
        if tmp(1)>tmp(2)
          theta(2)=axlim(2);
        end
      elseif inlim(1)
        theta(2)=axlim(2);
      elseif inlim(2)
        theta(1)=axlim(1);
      else
        theta = axlim;
      end
      
      %set cursor ngle limits to valid angles, but disable listeners first
      set(getappdata(0,'PolarCursorListeners'),'Enabled','off');
      fkGraphics.setradians(h, 'AngleLim', theta);
      set(getappdata(0,'PolarCursorListeners'),'Enabled','on');      
      
    end
    
    %clip radius data
    rho = clip_radius( parent, h.RadialLim, 'clip');

  else
    
    rho = h.RadialLim;
    
    %apply snapping
    if snapangle~=0
      theta = round(anglelim./snapangle).*snapangle;
    else
      theta = anglelim;
    end

  end  

  %create plot data
  rho = rho([1 end]);
  theta = theta([1 end]);
  
  if theta(1)>theta(2)
    theta(2)=theta(2)+2*pi;
  end
  
  %transform to cartesian coordinates
  [x, y] = pol2cart( repmat(theta(:),1,2), repmat(rho(:)',2,1) );

  %set line data
  set(h.hHandle(1), 'XData', x(1,1:2), 'YData', y(1,1:2));
  set(h.hHandle(2), 'XData', x(2,1:2), 'YData', y(2,1:2));
  
  %create patch data and convert to cartesian coordinates
  tmp = linspace( theta(1), theta(2), 50 )';
  [x, y] = pol2cart( [theta(1);tmp;flipud(tmp);theta(1)], ...
                     [rho(1);repmat(rho(2),50,1);repmat(rho(1),50,1);rho(1)]);

  %set patch data
  set(h.hHandle(3), 'XData', x, 'YData', y);
  
  %set flag
  h.Dirty='clean';
  
end

