function xs_new = unwrap_by (xs, target, varargin)
% UNWRAP_BY unwraps something like a phase angle
%   UNWRAP_BY (xs, target) treats target as the '2*pi' target

p = inputParser();
p.addParamValue('tol',target/2);
p.addParamValue('dim',[]);
p.parse(varargin{:});

if(isempty(p.Results.dim))
    
    scaled_unwrapped = unwrap( xs .* (2*pi) ./ target, p.Results.tol);
    
else
    
    scaled_unwrapped = unwrap(xs .* (2*pi) ./ target, p.Results.tol, p.Results.dim);
    
end

xs_new = target ./ (2*pi) .* scaled_unwrapped;