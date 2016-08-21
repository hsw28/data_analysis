function refresh(h)
%REFRESH refresh function for polar bar
%
%  REFRESH(h) redraw polar bar object
%

%  Copyright 2008-2008 Fabian Kloosterman

%do nothing if we're clean
if ~strcmp(h.Dirty,'clean')
    
  ndiv = 6;
  na = numel(h.AngleData);
  nr = numel(h.RadiusData);
  
  if isscalar(h.WidthData)
    w = repmat(h.WidthData,na,1);
  else
    w = h.WidthData(:);
  end
  
  nw = numel(w);

  %do we have data and are they consistent?
  if na~=nr || (nw~=na && nw~=0) || na==0
    
    %no the data is inconsistent
    %set data of line and patch objects to NaN
    set(h.hHandles(1), 'XData', NaN, 'YData', NaN);
    set(h.hHandles(2), 'XData', NaN, 'YData', NaN); 

    %set flag    
    h.Dirty = 'inconsistent';
    
  else

    %yes the data is consistent, let's draw it
    
    %get angle data in radians
    angledata = fkGraphics.getradians(h,'AngleData');
    
    %get parent axes
    parent = ancestor(double(h),{'axes'});
    
    if isa(handle(parent), 'fkGraphics.polaraxes') %polaraxes
      
      %get the polar axes object handle
      parent = handle(parent);
      
      %clip radius and angle data
      rho = clip_radius( parent, h.RadiusData(:), h.RadiusClip);
      theta = clip_angle( parent, angledata(:), h.AngleClip);      

      baseline = clip_radius( parent, h.Baseline, 'clip');

      %generate width data if necessary
      if nw==0
        %get polar axes angular limits in radians
        anglelim = fkGraphics.getradians(parent, 'AngleLim');

        %assume equal spacing
        w = repmat( abs( diff(anglelim)./na ), na, 1);
      end
      
    else
      
      %we're dealing with a normal axes
      %so no clipping necessary      
      
      theta = limit2pi(angledata(:));
      rho = h.RadiusData(:);
      
      if h.Baseline<0
        baseline=0;
      else
        baseline = h.Baseline;
      end
      
      %generate width data if necessary
      if nw==0
        %assume equal spacing
        w = repmat(2*pi/na,na,1);
      end      
      
    end
   
    %create coordinates
    T = bsxfun(@plus, theta, bsxfun(@times,w,linspace(-0.5,0.5,ndiv)) );
    R = repmat( rho, 1, ndiv );
    B = repmat( baseline, na, 1 );
           
    %convert to cartesian space
    [x,y] = pol2cart( cat(2,T(:,1),T,T(:,end),NaN(na,1))', cat(2,B,R,B,NaN(na,1))');
    
    %set line data
    set(h.hHandles(1),'XData', x(:), 'YData',y(:) );
      
    %convert patch data to cartesian space
    [x,y] = pol2cart( cat(2, T, fliplr(T))', cat(2,R,repmat(B,1,ndiv))' );

    %set patch data
    set(h.hHandles(2), 'XData',x, 'YData', y);
    
    %set flag
    h.Dirty='clean';    
    
  end
  
end