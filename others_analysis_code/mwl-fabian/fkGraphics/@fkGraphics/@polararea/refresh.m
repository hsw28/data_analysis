function refresh(h)
%REFRESH refresh function for polar area
%
%  REFRESH(h) redraw polar area object
%

%  Copyright 2008-2008 Fabian Kloosterman


%do nothing if we're clean
if ~strcmp(h.Dirty,'clean')

  na = numel(h.AngleData);
  nr = numel(h.RadiusData);
  
  %do we have data and are they consistent?
  if na~=nr || na==0
    
    %no the data is inconsistent
    %set data of line and patch objects to NaN
    set(h.hHandles(1), 'XData', NaN, 'YData', NaN);
    set(h.hHandles(2), 'XData', NaN, 'YData', NaN);    
    
    %set flag
    h.Dirty = 'inconsistent';
    
  else
    
    %yes the data is consistent, let's draw it

    %get angle data in radians
    angledata = fkGraphics.getradians(h, 'AngleData');
    
    %get parent axes
    parent = ancestor(double(h),{'axes'});
        
    if isa(handle(parent), 'fkGraphics.polaraxes')
      
      %get the polar axes object handle
      parent = handle(parent);
      
      %clip radius and angle data
      rho = clip_radius( parent, h.RadiusData(:), h.RadiusClip);
      theta = clip_angle( parent, angledata(:), h.AngleClip); 
      
      %create data for baseline
      %and clip angle and radius baseline data
      
      baseline = clip_radius( parent, h.Baseline, 'clip' );
      if baseline == 0
        theta_b = 0;
        rho_b = 0;
      else
        theta_b = clip_angle( parent, linspace(theta(end),theta(1),100)', h.AngleClip);
        rho_b = repmat(baseline,100,1);
      end
      
    else
      
      %we're dealing with a normal axes
      %so no clipping necessary
    
      theta = limit2pi(angledata(:));
      rho = h.RadiusData(:);
      
      %create data for baseline     
      if h.Baseline < 0
        theta_b = 0;
        rho_b = 0;
      else
        theta_b = linspace(theta(end),theta(1),100)';
        rho_b = repmat(h.Baseline,100,1);      
      end
      
    end

    %deal with auto closing
    if strcmp(h.AutoClose,'on')
      theta(end+1,1) = theta(1);
      rho(end+1,1) = rho(1);
      theta_b(end+1,1) = theta_b(1);
      rho_b(end+1,1) = rho_b(1);
    end
    
    %convert data to cartesian coordinates
    [x,y] = pol2cart(theta,rho);
    
    %set line data
    set(h.hHandles(1),'XData', x, 'YData', y);
      
    %convert baseline to cartesian coordinates
    [xb,yb] = pol2cart( theta_b, rho_b );

    %set patch data
    set(h.hHandles(2), 'XData', [x;xb], 'YData', [y;yb]);
    
    %set flag
    h.Dirty='clean';    
    
  end
  
end