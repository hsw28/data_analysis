function h=polararea(varargin)
%POLARAREA creates a polar area plot
%
%  h=POLARAREA plots a polar area plot of the function |sin(2*theta)|. A
%  handle to a polar area graphics object is returned.
%
%  h=POLARAREA(rho) plots a polar area of radius data at equally spaced
%  angles. If rho is a matrix, multiple area plots will be created.
%
%  h=POLARAREA(theta,rho) plots a polar area in the current axes using
%  the angle and radius data. Theta and rho can be either vectors or
%  matrices of the same size. Alternatively, theta can be a vector and
%  rho can be a matrix with the same number of rows as the length of
%  theta. In this case the function will create as many polar area plots
%  as there are columns in rho.
%
%  h=POLARAREA(hax,...) will plot in axes with handle hax.
%
%  h=POLARAREA(...,param1,val1,...) sets polar area properties
%  through parameter/value pairs. Execute set(h) to see a list of valid
%  properties that can be modified.
%

%  Copyright 2008-2008 Fabian Kloosterman

%get axes handle from arguments, if any
[hAx,args,nargs] = axescheck(varargin{:}); %#ok

%check arguments, extract angle and radius data
isnum1 = nargs>0 && isnumeric(varargin{1});
isnum2 = nargs>1 && isnumeric(varargin{2});

if ~isnum1
  rho=[];
  theta=[];
elseif ~isnum2
  rho=varargin{1};
  theta=[];
  args = args(2:end);
else
  theta = args{1};
  rho = args{2};
  args = args(3:end);
end

%make sure vectors are column vectors
if isvector(rho)
  rho=rho(:);
end
if isvector(theta)
  theta=theta(:);
end

hAx = newpolarplot( hAx );

if isempty(rho) && isempty(theta)
  h = fkGraphics.polararea(args{:},'Parent',hAx);
  return
else
  [npoints,nplots] = size(rho);
  if isempty(theta)
    theta = 2*pi*(0:(npoints-1))'/npoints;
  end
  if size(theta,1)~=npoints || (size(theta,2)~=nplots && ~isvector(theta))
    error('polararea:invalidData', 'Angle and radius data size mismatch')
  end
end

idx = linspace(1,size(theta,2),nplots);

for k=1:nplots
  
  h(k) = fkGraphics.polararea(args{:},'AngleData',theta(:,idx(k)), ...
                              'RadiusData', rho(:,k), 'Parent', hAx );
  
end
  

hAx = handle(hAx);
if isa(hAx,'fkGraphics.polaraxes')
  rl = hAx.RadialLim;
  set(hAx,'RadialLim',[rl(1) max(rl(2),max(rho(:)))]);
end