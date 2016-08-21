function validpts = inclPoints(points, include, exclude)
%INCLPOINTS select 2D coordinates based on inclusive and exclusive regions
%
%  b=INCLPOINTS(coordinates,include) for a nx2 matrix of 2d coordinates
%  returns true if the coordinate lies within the include boundaries and
%  false otherwise. Include boundaries can be a rectangle
%  ([x0,y0,width,height]) or polygon (nx2 list of node coordinates) or a
%  cell array of rectangles and/or polygons. If no inclide region is
%  specified, than the function returns true for all coordinates.
%
%  b=INCLPOINTS(coordinates,include,exclude) returns true for all
%  coordinates that are located within the include regions, but not
%  inside the exclude regions.
%
%  Example
%    incl = { [0 0 1 1] };
%    excl = { [0 0 0.5 0.5] };
%    p = inclPoints( rand(100,2), incl, excl );
%

%  Copyright 2005-2008 Fabian Kloosterman


% no arguments?
if (nargin<1)
    help(mfilename)
    return
end

% no include / exclude regions defined - return points without modification
if (nargin<2)
  validpts = true(size(points));
  return
end

% check points
if isempty(points)
    validpts = [];
    return
elseif ~isnumeric(points) || ndims(points)~=2 || size(points,1)<1 || size(points,2) ~= 2
    error('Invalid points')
end


% check include regions
if (~isempty(include))
    % make cell array
    if ~iscell(include)
        include = {include}; 
    end

    for i=length(include):-1:1
        if ( ~isrectdef(include{i}) && ~ispolygondef(include{i}) )
            warning(['Invalid include region definition: ' num2str(i)])
            include(i) = [];
        end
    end
else
    include = {};
end

if (nargin>2 && ~isempty(exclude))
    % check exclude regions

    % make cell array
    if ~iscell(exclude)
        exclude = {exclude};
    end

    for i=length(exclude):-1:1
        if ( ~isrectdef(exclude{i}) && ~ispolygondef(exclude{i}) )
            warning(['Invalid exclude region definition: ' num2str(i)])
            exclude(i) = [];
        end
    end    
else
    exclude = {};
end


% finally apply include / exclude boundaries

if isempty(include)
    validpts = ones(size(points,1),1);
else
    validpts = zeros(size(points,1),1); 
end

for i = 1:length(include)
    if isrectdef(include{i})
        validpts = validpts | inrect(points(:,1), points(:,2), include{i});
    else
        validpts = validpts | inpolygon(points(:,1), points(:,2), include{i}(:,1), include{i}(:,2));
    end
end

for i = 1:length(exclude)
    if isrectdef(exclude{i})
        validpts = validpts & ~inrect(points(:,1), points(:,2), exclude{i});
    else
        validpts = validpts & ~inpolygon(points(:,1), points(:,2), exclude{i}(:,1), exclude{i}(:,2));
    end
end



end


function isrect = isrectdef(x)
%ISRECTDEF - checks if x is a rectangle definition (i.e. 1x4 array)

isrect = ( ndims(x) == 2 & size(x,1) == 1 & size(x,2) == 4 );

end

function ispoly = ispolygondef(x)
%ISPOLYGONDEF - checks if x is a polygon definition (i.e. nx2 matrix)

ispoly = ( ndims(x) == 2 & size(x,1)>2 & size(x,2) == 2);

end
