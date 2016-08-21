function groups = imglabel(pts, radius)
%IMGLABEL find groups of connected pixels in sparse image
%
%  groups=IMGLABEL(xy,radius) finds all interconnected groups of pixels
%  in the xy vector of 2D coordinates. Radius defines the area
%  surrounding a pixels that is considered connected to that pixel
%  (default = 2). The function returns a cell array of 2D coordinate
%  arrays.
%

%  Copyright 2005-2006 Fabian Kloosterman

if nargin<1
    help(mfilename)
    return
end

if nargin<2 || isempty(radius)
    radius = 2;
end

radius = radius^2;

if ~isnumeric(pts) && size(pts, 1)<1 && size(pts,2)~=2
    error('imglabel:invalidArguments', 'Invalid points array.')
end

l = size(pts, 1);

current_group = 0;

while l>0
    
    current_group = current_group + 1;
    groups(current_group) = { pts(1,:) }; %#ok
    pts(1,:) = [];
    current_point = 1;
    
    ll = size(groups{current_group}, 1);
    
    while (current_point<=ll)

      pntdist = sum( bsxfun(@minus, pts , groups{current_group}(current_point,:)).^2, 2 );
      
        for ip = size(pts,1):-1:1
            
            if ( pntdist(ip) < radius )
                groups{current_group}(end+1,:) = pts(ip,:); %#ok
                pts(ip,:) = [];
            end
            
        end

        current_point = current_point+1;
        ll = size(groups{current_group}, 1); 
        
    end
    
    l = size(pts, 1);
end
