function refresh(h)
%REFRESH refresh function for polar area
%
%  REFRESH(h) redraw polar line object
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
    set(h.hLine, 'XData', NaN, 'YData', NaN);
    
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
      
    else
      
      theta = angledata(:);
      rho = h.RadiusData(:);
      
    end
 
    %deal with auto closing
    if strcmp(h.AutoClose,'on')
      theta(end+1,1) = theta(1);
      rho(end+1,1) = rho(1);
    end

    %transform data
    [x,y] = pol2cart( theta(:), rho(:) );
    
    %set line data
    set(h.hLine, 'XData', x, 'YData', y );
    
    %set flag
    h.Dirty='clean';
    
  end
  
end
