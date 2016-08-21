function f=compoundfilter(varargin)
%COMPOUNDFILTER create a compound filter function
%
%  f=COMPOUNDFILTER(filter1,[op,]filter2,...) returns a function that
%  will filter its inputs by sequentially applying the the specified
%  filters. Each pair of filters can (but doesn't have to) be connected
%  by one of the following logical operations: 'and', 'or', 'xor',
%  'not'. The default logical operation is 'or'.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1
  help(mfilename)
end

isfun=cellfun('isclass',varargin,'function_handle');
isop=cellfun('isclass',varargin,'char');
isop(isop) = isop(isop) & ismember(varargin(isop), {'and', 'or','xor','not'});

if ~all( isfun | isop )
  error('compoundfilter:invalidArgument', ['Invalid function handles and/or ' ...
                      'logical operators'])
end

filters = varargin;

f = @(x) internalfilter(x,filters);

function [x,b]=internalfilter(x,filters)

op = @or;
unop = @(x) x;

b = false(size(x));

for k=1:numel(filters)
  if ischar(filters{k})
    if strcmp(filters{k},'not')
      unop = @not;
    else
      op = str2func(filters{k});
    end
  else
    %filter
    [tmp,tmp] = filters{k}(x); %#ok
    b = op( b, unop(tmp) );
    %reset operators
    op = @or;
    unop = @(x) x;
  end
end
  
x = x(b);
