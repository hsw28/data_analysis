function spikevar=var2spike(spikes,vartime,variables,varargin)
%VAR2SPIKE computes the value of variables at time of spikes
%
%  spikevar=VAR2SPIKE(spikes,vartime,variables) returns the value of the
%  variables at the time of the spikes. The spike times argument can be a
%  vector of event times or a cell array with event time vectors. The
%  variable time argument should be a vector, the variables arguments
%  should be a matrix with the same number of rows as vartime.
%
%  spikevar=VAR2SPIKE(...,parm1,val1,...) uses the specified
%  options. Valid options are:
%   vartypes - specifies whether variables are linear (1) or circular
%   (0). Either a scalar, a vector or a cell array.
%   interp - interpolation method: nearest, linear, etc.
%   addtime - 0/1, include spike time in the output matrix
%
%  This function will interpolate the variables at the spike times. For
%  circular variables the variable will first be unwrapped, then
%  interpolated and finally converted back to radians again.
%
%  Example
%    vt = (0:100)';
%    v = [v.^2 mod(vt,2*pi)];
%    var2spike( 100*sort(rand(100,1)), vt, v, 'vartypes', {'l','c'})
%

%  Copyright 2007-2008 Fabian Kloosterman
  
if nargin<3
  help(mfilename)
  return
end

if isnumeric(spikes) && isvector(spikes)
  spikes={spikes};
elseif ~iscell(spikes)
  error('var2spike:invalidArgument', 'Invalid spikes')
end

if ~isvector(vartime)
  error('var2spike:invalidArgument', 'Invalid variable time')
end

if ~isnumeric(variables) || ndims(variables)~=2 || ...
      size(variables,1)~=numel(vartime)
  error('var2spike:invalidArgument', 'Invalid variables')
end

options = struct( 'vartypes', ones(1,size(variables,2)), ...
                  'interp', 'nearest', ...
                  'addtime', false);
options = parseArgs(varargin,options);

if isempty(options.vartypes)
  options.vartypes = ones(1,size(variables,2));
elseif isnumeric(options.vartypes) && isvector(options.vartypes) && numel(options.vartypes)==size(variables,2)
  options.vartypes = (options.vartypes~=0);
elseif iscellstr(options.vartypes) && numel(options.vartypes)==size(variables,2)
  options.vartypes = ~strncmp( options.vartypes, 'c', 1 );
else
  error('var2spike:invalidArgument', 'Invalid variable types')
end

%unwrap circular variables
variables(:,~options.vartypes) = unwrap( variables(:,~options.vartypes) );

%calculate variables for each spike train
warning('off','MATLAB:interp1:NaNinY')
spikevar = apply2cell( @fcn, [], spikes );
warning('on','MATLAB:interp1:NaNinY')

if numel(spikes)==1
  spikevar=spikevar{1};
end

  function y=fcn(x)
    if ~isempty(x)  
        %interpolation  
        y = interp1( vartime, variables, x, options.interp);
        %restore circular variables
        y(:,~options.vartypes) = mod(y(:,~options.vartypes),2*pi);
        if options.addtime
            y(:,end+1) = x(:);
        end
    else
        if options.addtime
            y = zeros(0,size(variables,2)+1);
        else
            y = zeros(0,size(variables,2));
        end
        
    end

  end

end
