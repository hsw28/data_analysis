function r = cmap(fun,e)
% CMAP(fun, e) maps a function f over a functor e,
%              reserving the structure of e

if(iscell(e))
    % Cell arrays are already in the right form
    r = cellfun(fun, e, 'UniformOutput', false);
elseif(isstruct(e))
    % Map over each element in the struct
    r = repmat( fun(e(1)), size(e) );  % preallocate the right type for e
    for n = 2:numel(e)
        r(n) = fun(e(n));
    end
elseif(ismatrix(e))
    % If not struct or cell-array, hope that 
    r = arrayfun(fun,e);
else
    error('cmap:unknown_input','cmap argument wasn''t struct, cell, or array');
end
