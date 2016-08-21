function refresh(h)
%REFRESH refresh function for polar bar
%
%  REFRESH(h) redraw polar bar object
%

%  Copyright 2008-2008 Fabian Kloosterman

%do nothing if we're clean
if ~strcmp(h.Dirty,'clean')
  
  na = numel(h.AngleData);
  nr = numel(h.RadiusData);
  ns = numel(h.SizeData);
  [ncr ncc] = size(h.ColorData);
  
  if (ncc==3)
    nc=ncr;
  elseif ncr==1 || ncc==1
    nc = ncr*ncc;
  else
    nc=0; %mark inconsistent
  end
  
   %do we have data and are they consistent?
  if na~=nr || (ns~=na && ns~=1) || na==0 || (nc~=na && nc~=1)
    
    %no the data is inconsistent
    %set data of scatter objects to NaN
    set(h.hScatter, 'XData', NaN, 'YData', NaN);
    
    %set flag    
    h.Dirty = 'inconsistent';
    
  else
    
    %get angle data in radians
    angledata = fkGraphics.getradians(h, 'AngleData');
  
    %get parent axes    
    parent = ancestor(double(h),{'axes'});    
    
    if isa(handle(parent), 'fkGraphics.polaraxes') %polaraxes
      
      %get the polar axes object handle
      parent = handle(parent);
      
      %oclip radius and angle data
      rho = clip_radius( parent, h.RadiusData(:), h.RadiusClip);
      theta = clip_angle( parent, angledata(:), h.AngleClip);
      
      %transform data
      [x,y] = pol2cart( theta(:), rho(:) );
      
    else
      
      [x,y] = pol2cart( angledata(:), h.RadiusData(:));
      
    end
    
    %set scatter data
    set(h.hScatter, 'XData', x, 'YData', y, 'CData', h.ColorData, 'SizeData', h.SizeData);

    %set flag
    h.Dirty='clean';
    
  end
  
end