function schema
%SCHEMA class definition for shapes on curve object
%
%  SCHEMA
%

%  Copyright 2008-2008 Fabian Kloosterman

%-------DEFINE CLASS-------

%get animation package
pkg = findpackage('fkGraphics');
%get handle graphics package
pkgHG = findpackage('hg');

%define animaxes class
h = schema.class(pkg,'shapesoncurve', pkgHG.findclass('patch'));
h.Description = 'Shapes on curve';

%-------DEFINE PROPERTIES-------

%Curve property
p = schema.prop(h,'Curve','MATLAB array'); %#ok
p.Description='Curve property';
p.FactoryValue=[];

%Scale property
p = schema.prop(h,'Scale','MATLAB array'); %#ok
p.Description='Scale property';
p.FactoryValue=1;

%Reference point property
p = schema.prop(h,'RefPoint','MATLAB array'); %#ok
p.Description='Reference point property';
p.FactoryValue=[0 0];

%Offset property
p = schema.prop(h,'Offset','MATLAB array'); %#ok
p.Description='Offset property';
p.FactoryValue=[0 0];

%Shape property
p = schema.prop(h,'Shape','MATLAB array'); %#ok
p.Description='Shape property';
p.FactoryValue=[-0.5 -0.5; 0 0.5; 0.5 -0.5]';

%Curvature property
p = schema.prop(h,'Curvature','MATLAB array'); %#ok
p.Description='Curvature';
p.FactoryValue=0;

%Color property (dummy property)
p = schema.prop(h,'Color','MATLAB array'); %#ok
p.Description='Color property';
p.FactoryValue=[0 0 0];

%Alpha property (dummy property)
p = schema.prop(h,'Alpha','MATLAB array'); %#ok
p.Description='Alpha property';
p.FactoryValue=1;



%-------SETTERS/GETTERS-------

p = h.findprop('Color');
set(p, 'SetFunction', @setColor);

p = h.findprop('Shape');
set(p, 'SetFunction', @setShape);


%-------LISTENERS-------
l = handle.listener(h, [h.findprop('Color') h.findprop('Curve')], ...
                    'PropertyPostSet', @updateColor);
l(end+1) = handle.listener(h, [h.findprop('Alpha') h.findprop('Curve')], ...
                    'PropertyPostSet', @updateAlpha);
l(end+1) = handle.listener(h, [h.findprop('Shape') h.findprop('Curve') h.findprop('Scale') h.findprop('Offset') h.findprop('RefPoint') h.findprop('Curvature')], ...
                           'PropertyPostSet', @updateCurve);


%property to store listeners
p = schema.prop(h, 'PropertyListeners', 'handle vector'); %#ok
p.Description='Handles of property listeners';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible='off';
p.FactoryValue = l;



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

if nshapes == 1
    h.FaceColor = h.Color;
else

    if r==1 && p~=1
        h.CData = permute( repmat( h.Color, [nshapes, 1, 1]), [3 1 2]);
    else
        h.CData = permute( h.Color, [3 1 2]);
    end
    
    h.FaceColor = 'flat';
    
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
ctop = bsxfun( @plus,  zeros(size(y)), h.Curvature(:,1) );
cbottom = bsxfun( @plus, zeros(size(y)), h.Curvature(:,end) );
cc = 1 ./ ctop;
cc(y<0) = 1./cbottom(y<0);
rr = abs(bsxfun(@minus,cc,x));
alpha = bsxfun(@rdivide,y, rr);
valid_alpha = alpha~=0;
tmp = bsxfun(@times, sin(alpha), rr );
y(valid_alpha) = tmp(valid_alpha);
tmp = bsxfun(@plus, bsxfun(@times, sign(cc), bsxfun(@minus,rr,  bsxfun(@times,cos(alpha), rr ) ) ),x);
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