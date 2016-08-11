function [lindex varargout] = localmax(x)
% LOCALMAX find indexes of local maxima in an array
%from http://www.mit.edu/~pwb/cssm/matlab-faq.html
%
% operates column-wise on matrices
%
%  [lindex values] = localmax(x)
%
%  li: a logical index into x which is true at local maxima of x
%  values: cell array of index/value pairs at the local maxima for each
%  column (same # of rows as sum(lindex) for that column)
  
%  lindex = diff( sign( diff([0; x(:); 0]) ) ) < 0;
 
  if ndims(x) > 2, 
    error('localmax only supports up to 2-dimensional arrays');
  end
  
  [nrows ncols] = size(x); %#ok
  
  lindex = diff( sign( diff([zeros(1,ncols); x; zeros(1,ncols)]))) < 0;
  
  % only compute this if requested
  if nargout > 1;
    for k = 1:ncols,
      vals{k} = [find(lindex(:,k)) x(lindex(:,k),k)];
    end
    
    varargout(1) = {vals};
  end