function [hObj, point] = get_pointer_object( hFig, point, option )
%GET_POINTER_OBJECT get object under mouse cursor
%
%  [hObj,local_point]=GET_POINTER_OBJECT(hFig, screen_point) finds in the
%  figure with handle hFig the front-most object at the location of the
%  mouse cursor that has its HitTest property set to 1. The coordinates
%  screen_point will be transformed to local coordinates local_point. For
%  a figure or uipanel local coordinates mean the pixel coordinates
%  relative to the bottom-left corner. For an axes it means the axes
%  coordinate system. For other objects this means the local coordinates
%  of their parent container (i.e. figure, uipanel or axes).
%
%  [hObj,point]=GET_POINTER_OBJECT(hObj, point, 1) will only transform
%  the screen coordinates to local coordinates for the object with handle
%  hObj.
%

%  Copyright (C) 2006 Fabian Kloosterman
%
%  This program is free software; you can redistribute it and/or modify it
%  under the terms of the GNU General Public License as published by the
%  Free Software Foundation; either version 2 of the License, or (at your
%  option) any later version.
%
%  This program is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
%  Public License for more details.
%
%  You should have received a copy of the GNU General Public License along
%  with this program; if not, write to the Free Software Foundation, Inc.,
%  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 


%should we perform a hit test?
if nargin<3 || option==0
  
  %find object at mouse pointer
  hObj = hittest(hFig);  

else
  hObj = hFig;
end

%now we've found the object at the mouse pointer location
%let's transform the screen point to local coordinates

%get the type of the object
h = hObj;
obj_type = get( h, 'Type' );

%if the object is not a figure, uipanel or axes, then finds its parent
%container
if ~any(strcmp( obj_type, {'figure', 'uipanel', 'axes'} ) )
  %parent = ancestor( h, 'axes' );
  parent = get_parent_container(h, 'axes');
  obj_type = 'axes';
  if parent==0
    %parent = ancestor( h, 'uipanel' );
    parent = get_parent_container(h, 'uipanel');
    obj_type = 'uipanel';
    if parent==0
      %parent = ancestor( h, 'figure' );
      parent = get_parent_container(h, 'figure');
      obj_type = 'figure';
    end
  end
  h = parent;
end


%calculate local coordinates based on object type
if strcmp( obj_type, 'figure')

  p = get( h, 'PixelBounds' );
  point(2) = p(4)-point(2); %flip y coordinate
    
elseif strcmp( obj_type, 'axes')
  
  point = get( h, 'CurrentPoint' );
  point = point(1,1:2);
          
else
  
  p = get( h, 'PixelBounds' );
  point = [ point(1)-p(1) p(4)-point(2) ];
    
end

    


function h = get_parent_container( h, tp )

if ~strcmp(get(h,'Type'),tp) && h~=0
  h = get_parent_container(get(h,'Parent'),tp);
end