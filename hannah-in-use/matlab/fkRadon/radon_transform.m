function varargout = radon_transform( M, varargin )
%RADON_TRANSFORM computes radon transform
%
%  r=RADON_TRANSFORM(m) computes radon transform of matrix m using
%  default options.
%
%  r=RADON_TRANSFORM(m,theta) computes the radon transform at the
%  specified angles.
%
%  r=RADON_TRANSFORM(m,theta,rho) computes the radon transform at the
%  specified angles and rho values.
%
%  r=RADON_TRANSFORM(...,parm1,val1,...) specifies optional
%  parameters. Valid options are:
%   dx - sample size in row dimension (default=1)
%   dy - sample size in column dimension (default=1)
%   interp - interpolation method: 'nearest' or 'linear'
%            (default='nearest')
%   method - method of how matrix elements are combined: 'integral',
%            'sum', 'mean', 'product', 'slice' (default='integral'). If
%            method is 'slice', then for each theta,rho pair the
%            projection along the line defined by this pair is returned.
%   valid - 0/1 compute radon for all possible lines or for valid lines
%           only. Valid lines span the complete width and/or height of
%           matrix m. (default=0)
%   rho_x - 0/1 indicates whether rho specifies the distance to the
%           origin or the intercept on the horizontal axis. (default=0)
%   constraint - 'none'/'x'/'y', combine matrix elements in x or y
%                direction only, or decide based on angle of line
%                (default='none')
%   theta_range - range of theta values (in case no theta values are
%                 specified) (default=[-0.5 0.5]*pi). Theta values are
%                 sampled optimally within this range.
%   dtheta - theta sampling interval; in combination with theta_range
%            this defines the angles at which to compute the radon
%            transform (only used if no theta values are
%            specifed). If empty, the optimal interval is
%            computed.(default=[])
%   rho_range - range of rho values (in case no rho values are
%               specified). If empty, the range of rho values is computed
%               based on the size of the matrix and the theta
%               range. (default=[])
%   drho - rho sampling interval; in combination with rho_range this
%          defines the rho values at which to compute the radon transform
%          (only used if no rho values are specified). If empty, the
%          optimal interval is computed (default=[])
%


options = struct( 'dx', 1, ...
                  'dy', 1, ...
                  'interp', 'nearest', ...
                  'method', 'integral', ...
                  'valid', 0, ...
                  'rho_x', 0, ...
                  'constraint', 'none', ...
                  'theta_range', [-0.5 0.5].*pi, ...
                  'dtheta', [], ...
                  'rho_range', [], ...
                  'drho', []);

[options,other] = parseArgs(varargin, options);

[nx,ny]=size(M);

theta = [];
rho = [];

%get theta and rho arguments
if ~isempty(other)
  
  theta = other{1};
  
  if numel(other)>1
    rho = other{2};
  end
  
end

%create theta vector, if not already specified
if isempty(theta)
  
  if isempty(options.dtheta)
    [options.dtheta, options.theta_range, n] = radon_optimal_theta( options.dx, options.dy, nx, ny, options.theta_range); %#ok  
  end
  
  theta = options.theta_range(1):options.dtheta:options.theta_range(2);

end

%create rho vector, if not already specified
if isempty(rho)
  
  if isempty(options.rho_range) || isempty(options.drho)
    [drho, rho_range, n] = radon_optimal_rho( options.dx, options.dy, nx, ny, options.theta_range, options.rho_x ); %#ok
    if isempty(options.rho_range)
      options.rho_range = rho_range;
    end
    if isempty(options.drho)
      options.drho = drho;
    end
  end
  
  rho = options.rho_range(1):options.drho:options.rho_range(2); 
  
end

%interpolation
switch lower(options.interp)
 case {'nearest', 'n', 'nn'}
  options.interp = 'nearest';
  interp = 0;
 case {'linear', 'l', 'lin'}
  options.interp = 'linear';
  interp = 1;
 otherwise
  error('radon_transform:invalidArgument', ['Invalid interpolation ' ...
                      'method'])
end
  
%method
switch lower(options.method)
 case {'sum', 's'}
  options.method='sum';
  method=1;
 case {'integral', 'i', 'int'}
  options.method='integral';
  method=0;
 case {'mean', 'm'}
  options.method='mean';
  method=2;
 case {'product', 'p'}
  options.method='product';
  method=4;  
 case {'logsum', 'l'}
  options.method ='logsum';
  method=5;
 case {'slice'}
  options.method='slice';
  method=3;  
 otherwise
  error('radon_transform:invalidArgument', 'Invalid radon method')
end

%constraint
switch lower(options.constraint)
 case 'none'
  options.constraint='none';
  constraint=0;
 case {'x','row','rows'}
  options.constraint='x';
  constraint=1;
 case {'y','col','column','columns'}
  options.constraint='y';
  constraint=2;
 otherwise
  error('radon_transform:invalidArgument', 'Invalid constraint')
end


%compute radon transform
varargout = {};

[rd, nn] = general_radon_c( theta, rho, M, options.dx, options.dy, interp, method, ...
                                     constraint, options.valid, options.rho_x );


varargout{1} = rd;

if nargout>1
  varargout{2} = nn;
end

if nargout>2
  varargout{3} = struct( 'theta', theta, 'rho', rho, 'options', options, ...
                         'xmin', -options.dx.*(nx-1)./2, 'ymin', -options.dy.*(ny-1)./2);
end

