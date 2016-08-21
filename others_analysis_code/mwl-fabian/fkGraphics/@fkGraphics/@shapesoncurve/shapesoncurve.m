function h=shapesoncurve(varargin)
%SHAPESONCURVE shapes on curve constructor
%
%  h=SHAPESONCURVE(param1,val1,...)
%


%  Copyright 2008-2008 Fabian Kloosterman


%find parent parameter if any
parent_ind = find( strncmpi( varargin(1:2:end), 'parent',6 ) );
if ~isempty(parent_ind)
  parent = varargin{parent_ind*2};
else
  parent = gca;
end

%remainder of arguments
args = varargin( setdiff( 1:nargin, [2*parent_ind-1 2*parent_ind] ) );

h = fkGraphics.shapesoncurve('XData', [],'YData',[],'Parent', ...
                             double(parent));


% $$$ %-------SETTERS/GETTERS-------
% $$$ 
% $$$ p = h.findprop('Color');
% $$$ set(p, 'SetFunction', @setColor);
% $$$ 
% $$$ p = h.findprop('Shape');
% $$$ set(p, 'SetFunction', @setShape);
% $$$ 
% $$$ 
% $$$ %-------LISTENERS-------
% $$$ l = handle.listener(h, [h.findprop('Color') h.findprop('Curve')], ...
% $$$                     'PropertyPostSet', @updateColor);
% $$$ l(end+1) = handle.listener(h, [h.findprop('Alpha') h.findprop('Curve')], ...
% $$$                     'PropertyPostSet', @updateAlpha);
% $$$ l(end+1) = handle.listener(h, [h.findprop('Curve') h.findprop('Scale') h.findprop('Offset') h.findprop('RefPoint') h.findprop('Curvature')], ...
% $$$                            'PropertyPostSet', @updateCurve);
% $$$ 
% $$$ h.PropertyListeners = l;


%-------FINALIZE-------


%make sure to set Curve property first
curve_ind = find( strncmpi( args(1:2:end), 'curve', 5) );
if ~isempty(curve_ind)
  set(h, 'Curve', args{curve_ind+1});
  args(curve_ind+[0 1])=[];
end

%set remaining arguments
if ~isempty(args)
  set(h,args{:});
end



function val = setColor(h, val)
if ndims(val)>3 || ( size(val,2)~=1 && size(val,2)~=3) 
  error('shapesoncurve:set:invalidArgument',['Color matrix has too ' ...
                      'many dimensions or incorrect size']);
end


function val = setShape(h, val)
[r,c] = size(val);
m = max( abs( val(:) ) );

if r~=2 && c==2
  val = val'./m;
elseif r==2
  val = val./m;
else
  error('shapesoncurve:set:invalidArgument', 'Invalid shape')
end


function updateColor(hProp, eventdata)
h = eventdata.affectedObject;
[r,c,p]=size(h.Color);

nshapes = size(h.Curve,1)-3+size(h.Curve,2);

if r==1 && p~=1
  h.CData = permute( repmat( h.Color, [nshapes, 1, 1]), [3 1 2]);
else
  h.CData = permute( h.Color, [3 1 2]);
end

function updateAlpha(hProp, eventdata)
h = eventdata.affectedObject;
[r,c]= size(h.Alpha);

nshapes = size(h.Curve,1)-3+size(h.Curve,2);

if r==1 && c~=1
  h.FaceVertexAlphaData = repmat( h.Alpha(:), [nshapes 1] );
  h.FaceAlpha = 'interp';
elseif r~=1 && c~=1
  h.FaceVertexAlphaData = reshape( h.Alpha', [prod(size(h.Alpha)) 1] );
  h.FaceAlpha = 'interp';  
else
  h.FaceVertexAlphaData = h.Alpha(:);
  h.FaceAlpha = 'flat';
end

function updateCurve(hProp, eventdata)
h = eventdata.affectedObject;
if isempty(h.Curve)
  return
end

if size(h.Curve,2)==3
  d = h.Curve(:,3);
  xy = h.Curve(:,1:2);
else
  d = atan2( diff(h.Curve(:,2)), diff(h.Curve(:,1)) ) -0.5*pi;
  xy = ( h.Curve(1:end-1,:) + h.Curve(2:end,:) )/2;
end

npoints = size(xy,1);

%compute coordinates
%reference point and scale
x = bsxfun(@times, h.Scale(:,1), h.Shape(1,:) - h.RefPoint(1) );
y = bsxfun(@times, h.Scale(:,end), h.Shape(2,:) - h.RefPoint(2) );
if size(y,1)==1 && npoints>1
  y = repmat(y, npoints,1);
  x = repmat(x, npoints,1);
end
%curvature
ws=warning('off', 'MATLAB:DivideByZero');
ctop = bsxfun(@plus, zeros(size(y)), h.Curvature(:,1) );
cbottom = bsxfun(@plus, zeros(size(y)), h.Curvature(:,end) );
cc = 1 ./ ctop;
cc(y<0) = 1./cbottom(y<0);
rr = abs(bsxfun(@minus,cc,x));
alpha = bsxfun(@rdivide,y, rr);
valid_alpha = alpha~=0;
tmp = bsxfun(@times, sin(alpha), rr );
y(valid_alpha) = tmp(valid_alpha);
tmp = bsxfun(@plus,bsxfun(@times, sign(cc), bsxfun(@minus,rr,  bsxfun(@times, cos(alpha), rr ) ) ),x);
x(valid_alpha)=tmp(valid_alpha);
warning(ws)
%offset
x = x - h.Offset(1);
y = y - h.Offset(2);

cosd = cos(d(:));
sind = sin(d(:));

xx = bsxfun(@plus, xy(:,1), bsxfun(@times, x, cosd ) - bsxfun(@times, y, sind ) );
yy = bsxfun(@plus, xy(:,2), bsxfun(@times, x, sind ) + bsxfun(@times, y, cosd ) );

h.XData=xx';
h.YData=yy';