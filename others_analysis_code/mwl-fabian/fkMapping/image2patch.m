function [vert, fac, col] = image2patch(img, varargin)
%IMAGE2PATCH convert an image to patches
%
%  [vertices,faces,color]=IMAGE2PATCH(img) convert image to patches and
%  return the vertices, faces and colors for those patches.
%
%  [...]=IMAGE2PATCH(img, parm1, val1, ...) specify optional
%  parameters. Valid paremeters are:
%   Edges - image pixel edges. Can be a cell array of edges for x and y
%    dimension. Can also be a numeric array: if this array has 2
%    elements it specifies the upper edge in x and y dimension (lower edge
%    is assumed 0). If the array has 4 elements, it specifies the lower
%    and upper edges of the x and y dimensions of the image. The
%    remaining edges are computed by interpolation.
%   Centers - image pixels centers. Accepts values similar to Edges
%    parameters (lower center is assumed 1, if not provided).
%
%  Convert a grayscale or rgb image to a collection of patches. The
%  function returns a matrix of patch vertices, a matrix of faces and a
%  matrix of colors. Use the output as follows:
%  patch('Faces',fac,'Vertices',vert,'FaceVertexCData',col,'FaceColor', 'flat')
%
%  Note: use either Edges or Centers, but not both
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<1
    help(mfilename)
    return;
end

args = struct('Edges', [], 'Centers', []);
args = parseArgs(varargin, args);

[imgy, imgx, imgc] = size(img);

if isempty(args.Edges) && isempty(args.Centers)
    % use image size as centers
    [iy, ix] = size(img);
    isize = [1 ix; 1 iy];
    delta = 0.5* diff(isize,1,2) ./ ( [imgx ; imgy]-1 );
    [mx, my] = meshgrid(linspace(isize(1,1)-delta(1), isize(1,2)+delta(1), imgx+1), linspace(isize(2,1)-delta(2), isize(2,2)+delta(2), imgy+1));   
elseif ~isempty(args.Edges) && ~isempty(args.Centers)
    error('Please specify edges OR centers and not both.')
elseif ~isempty(args.Edges)
    if isnumeric(args.Edges)
        if numel(args.Edges)<=2
            isize = [0 args.Edges(1) ; 0 args.Edges(end)];
        elseif numel(args.Edges)==4
            isize = [args.Edges(1) args.Edges(2); args.Edges(3) args.Edges(4)];
        else
            error('Invalid edges')
        end
        [mx, my] = meshgrid(linspace(isize(1,1), isize(1,2), imgx+1), linspace(isize(2,1), isize(2,2), imgy+1));
    elseif iscell(args.Edges) && numel(args.Edges)==2 && numel(args.Edges{1})==imgx+1 && numel(args.Edges{2})==imgy+1
        [mx, my] = meshgrid(args.Edges{1}(:), args.Edges{2}(:));
    else
        error('Invalid edges')
    end
else %centers
    if isnumeric(args.Centers)
        if numel(args.Centers)<=2
            isize = [1 args.Centers(1) ; 1 args.Centers(end)];
        elseif numel(args.Centers)==4
            isize = [args.Centers(1) args.Centers(2); args.Centers(3) args.Centers(4)];
        else
            error('Invalid centers')
        end
        delta = 0.5* diff(isize,1,2) ./ ( [imgx ; imgy]-1 );
        [mx, my] = meshgrid(linspace(isize(1,1)-delta(1), isize(1,2)+delta(1), imgx+1), linspace(isize(2,1)-delta(2), isize(2,2)+delta(2), imgy+1));
    elseif iscell(args.Centers) && numel(args.Centers)==2 && numel(args.Centers{1})==imgx && numel(args.Centers{2})==imgy
        delta1 = diff(args.Centers{1}(:)) ./ 2;
        delta1 = [args.Centers{1}(:); args.Centers{1}(end)] + [-delta1(1); -delta1; delta1(end)];
        delta2 = diff(args.Centers{2}(:)) ./ 2;
        delta2 = [args.Centers{2}(:); args.Centers{2}(end)] + [-delta2(1); -delta2; delta2(end)];        
        [mx, my] = meshgrid( delta1, delta2);   
    else
        error('Invalid edges')
    end    
end


[xx, yy] = meshgrid(1:imgx, 1:imgy);

fac(:,1) = sub2ind([imgy+1 imgx+1], yy(:), xx(:));
fac(:,2) = sub2ind([imgy+1 imgx+1], yy(:)+1, xx(:));
fac(:,3) = sub2ind([imgy+1 imgx+1], yy(:)+1, xx(:)+1);
fac(:,4) = sub2ind([imgy+1 imgx+1], yy(:), xx(:)+1);

vert = [mx(:) my(:)];

col = reshape(img, imgy*imgx, imgc);

if ~isa(col, 'double') && size(col,2)==3
    %assume it col contains rgb values as integers
    col = (double(col)-1)/255;
end

invalids = find( isnan(col(:,1)) );

fac(invalids,:) = [];

col(invalids, :) = [];
