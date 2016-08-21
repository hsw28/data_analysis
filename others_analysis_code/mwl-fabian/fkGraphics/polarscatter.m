function h=polarscatter(varargin)
%POLARSCATTER creates a polar scatter plot
%
%  h=POLARSCATTER plots a polar scatter plot of random data. A
%  handle to a polar scatter graphics object is returned.
%
%  h=POLARSCATTER(theta,rho) plots a polar scatter plot in the current
%  axes using the angle and radius data. Theta and rho should be vector
%  of the same length.
%
%  h=POLARSCATTER(theta,rho,size) sets size data for each marker, which
%  can either be a scalar or a vector the same size as theta and rho.
%
%  h=POLARSCATTER(theta,rho,size,color) sets color for each marker, which
%  can either be an index into the colormap, a rgb color vector or a
%  color string. The color argument can be a scalar or should be the same
%  length as theta and rho.
%
%  h=POLARBAR(hax,...) will plot in axes with handle hax.
%
%  h=POLARBAR(...,param1,val1,...) sets polar scatter properties
%  through parameter/value pairs. Execute set(h) to see a list of valid
%  properties that can be modified.
%

%  Copyright 2008-2008 Fabian Kloosterman


%get axes handle from arguments, if any
[hAx,args,nargs] = axescheck(varargin{:});

%check arguments, extract angle, radius, size and color data
isnum1 = nargs>0 && isnumeric(args{1});
isnum2 = nargs>1 && isnumeric(args{2});
isnum3 = nargs>2 && isnumeric(args{3});
isnum4 = nargs>3 && isnumeric(args{4});

if ~isnum1
  %plot random data
  hAx = newpolarplot( hAx );
  h = fkGraphics.polarscatter(args{:},'Parent',hAx);
  return  
elseif ~isnum2
  error('polarscatter:invalidData', 'No radius data')
end

if isnum3
  if isnum4
    args = {'SizeData' args{3} 'ColorData' args{4} args(5:end) };
  else
    args = {'SizeData' args{3} 'ColorData' repmat([0 0 0],numel(varargin{1}),1) args{4:end} };
  end
else
  args = {'SizeData' repmat(25,numel(varargin{1}),1) 'ColorData' repmat([0 0 0],numel(varargin{1}),1) args{3:end}};
end
  
hAx = newpolarplot( hAx );

h = fkGraphics.polarscatter(args{:}, 'AngleData', varargin{1}, 'RadiusData', varargin{2}, 'Parent', hAx);

hAx = handle(hAx);
if isa(hAx,'fkGraphics.polaraxes')
  rl = hAx.RadialLim;
  set(hAx,'RadialLim',[rl(1) max(rl(2),max(varargin{2}(:)))]);
end