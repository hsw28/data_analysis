function refresh(h)
%REFRESH refresh children
%
%  REFRESH(h) refresh polar plot and polar cursor children of polar axes
%  h.
%

% Copyright 2008-2008 Fabian Kloosterman

%only refresh when the axes is dirty
if ~strcmp(h.Dirty, 'clean')

  %find all hggroup children
  hChild = findobj(double(h), 'type', 'hggroup');
  
  %loop through children
  for k=1:numel(hChild)
    
    hc = handle(hChild(k));
    
    %is the child a polar plot / cursor?
    cl = class( hc );
    if any(strcmp(cl, {'fkGraphics.polarline', 'fkGraphics.polarscatter', ...
                       'fkGraphics.polarbar', 'fkGraphics.polararea', ...
                       'fkGraphics.polarcursor'}))
      
      %yes, so let's force an update
      set( hc, 'Dirty', 'invalid');
      
      %refresh( hc );
      
    end
    
  end
  
  %now we're clean again
  h.Dirty='clean';

end