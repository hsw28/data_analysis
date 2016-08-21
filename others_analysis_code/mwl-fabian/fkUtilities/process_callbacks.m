function varargout = process_callbacks( fcn, varargin )
%PROCESS_CALLBACKS process callback functions
%
%  [...]=PROCESS_CALLBACKS(fcn,...) processes callback functions and
%  returns the results.
%


%  Copyright 2005-2008 Fabian Kloosterman

if isstruct( fcn )
  for k=1:numel(fcn)
    
    try
      if ischar( fcn(k).fcn )
        evalin('base', fcn(k).fcn );
      elseif isa(fcn(k).fcn, 'function_handle')
        [varargout{1:nargout}] = feval( fcn(k).fcn, varargin{:} );
      else
        [varargout{1:nargout}] = feval( fcn(k).fcn{1}, varargin{:}, fcn(k).fcn{2:end} );
      end
    catch
      disp(lasterr)
    end
    
  end
  
else
  
  try
    if ischar( fcn )
      evalin('base', fcn );
    elseif isa(fcn, 'function_handle')
      [varargout{1:nargout}] = feval( fcn, varargin{:} );
    else
      [varargout{1:nargout}] = feval( fcn{1}, varargin{:}, fcn{2:end} );
    end
  catch
    disp(lasterr)
  end
  
end
