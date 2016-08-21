function mp=bin2map(bins,varargin)
%BIN2MAP create histogram of variables at binned coordinates
%
%  m=BIN2MAP(bins) constructs a histogram given the set of bins. Each row
%  in the bin matrix is a binned coordinate (i.e. an index into a grid),
%  each column is a dimension. By default the number of bins in the
%  histogram for each coordinate dimension is max( bins ).
%
%  m=BIN2MAP(bins,vars) applies the mapping function to the variable. The
%  variable matrix should have the same number of rows as the bins
%  matrix and can have an arbitrary number of additional
%  dimensions. Generally, the variable is a scalar and the vars
%  argument is a column vector. However, the variable can be any
%  n-d matrix, in which case the vars argument would be a
%  nrows-by-m-by-n-by... matrix. By default the var argument is a
%  column vector of ones. 
%
%  m=BIN2MAP(bins,parm1,val1,...) uses specified options. Valid options
%  are:
%   default - default value for empty bins (default = NaN)
%   function - function to apply to variables in each bin (default =
%              @size). The function should do its computation along the
%              first dimension of the input matrix. To enforce this for
%              some common functions (e.g. mean), the second argument is
%              always 1. Functions for which the dim argument is not the
%              second argument should be wrapped in an anonymous function.
%              For example: @(x,dim) std(x,0,dim).
%   size - size of histogram (i.e. vector of maximum bin index for each
%          dimension)
%

%similar functionality as accumarray, but in R14(SP1) accumarray has a
%bug and accumarray only support scalar variables

%  Copyright 2007-2008 Fabian Kloosterman


%check arguments
if nargin<1
  help(mfilename)
  return
end

options=struct('default',NaN,'function',@size,'size',[]);
[options,other]=parseArgs(varargin,options);

%determine number of coordinates and number of dimensions
[n,m]=size(bins);

%check variable
if isempty(other)
  vars=[];
else
  vars=other{1};
end

if isempty(vars)
  vars=ones(n,1);
elseif ~isnumeric(vars) || size(vars,1)~=n
  error('bin2map:invalidArguments', 'Invalid variables')
end

%determine variable dimensions
varndims = ndims(vars);
varsize = size(vars);

%check map size
if isempty(options.size)
  mapsize = max(bins,1);
else
  mapsize = options.size(:)';
end

if numel(mapsize)~=m && m>0
  error('bin2map:invalidArgument', 'Invalid size option')
end


%preallocate map
mp = zeros( [mapsize varsize(2:end)] ) + options.default;

%early exit
if m==0 ||  n==0
  return
end

%look for valid coordinates
valids = all(bins,2);

%early exit if no valid coordinates
if ~any(valids)
  return
end

%find unique coordinates
[b,i,j] = unique(bins(valids,:), 'rows'); %#ok

%convert to cell array
[rb, cb] = size(b);
b = mat2cell(b, ones(rb,1), ones(cb,1));

%create indexing vector
tmpidx = repmat({':'}, 1, varndims-1);

%select valid variables
vars = vars(valids, tmpidx{:});

%some magic
[js, ijs] = sort( j );
[jc,jc] = mmrepeat(js); %#ok
jc = [0; cumsum(jc)];

%loop through all unique coordinates
for d=1:rb

    %apply function to first dimension of variable
    mp(b{d,:}, :) = options.function( vars( ijs( (jc(d)+1):jc(d+1)  ), : ), 1 );  

end
