function [varargout] = nlinfitsome(fixed,x,y,fun,beta0,varargin)
% "fixed" indicats which values of beta0 should not change

% Get separate arrays of coefficients to fix and to estimate 
bfixed = beta0(fixed); beta0 = beta0(~fixed);

% Estimate only the non-fixed ones
[varargout{1:max(1,nargout)}] = nlinfit(x,y,@localfit,beta0,varargin{:});

% Re-create array combining fixed and estimated coefficients
b(~fixed) = varargout{1};
b(fixed) = bfixed;
varargout{1} = b;

   % Nested function takes just the parameters to be estimated as inputs
   % It inherits the following from the outer function:
   %   fixed = logical index for fixed elements
   %   bfixed = fixed values for these elements
   % but its input is the 
   function y=localfit(beta,x)
   
   b(fixed) = bfixed;
   b(~fixed) = beta;
   y = fun(b,x);
   end
end
