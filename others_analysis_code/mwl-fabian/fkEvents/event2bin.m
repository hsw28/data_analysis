function m=event2bin(events,bins,varargin)
%EVENT2BIN count events in bins
%
%  c=EVENT2BIN(events,bins) return a matrix of event counts for each
%  bin. The size of the matrix is: #events x #bins. The events argument
%  should be a vector or a cell array of vectors. The bins argument
%  should be a nx2 matrix, in which each row defines the start and end of
%  a bin.
%
%  c=EVENT2BIN(events,bins,parm1,val1,...) set optional parameters. Valid
%  parameters are:
%   method - 'count', 'binary', 'rate'
%

%we need at least two arguments
if nargin<2
  help(mfilename)
  return
end

%parse options
options=struct('method', 'count');
options = parseArgs(varargin,options);

%if a single event vector is given
%make it a cell array
if ~iscell(events)
  events = {events};
end

valid = cellfun( @(x) isnumeric(x) & isvector(x), events );
if ~all(valid)
    error('event2bin:invalidArgument', 'Invalid event vectors')
end

if ~( isnumeric(bins) && (isvector(bins) || (ndims(bins)==2 && size(bins,2)==2)) )
    error('event2bin:invalidArgument', 'Invalid bin array')
end

if isvector(bins)
    bins = bins(:);
    bins = [bins(1:end-1) bins(2:end)];
end

%sort the bins according to the first edge if needed
sortflag = false;
if ~issorted(bins(:,1))
    [bins, sidx] = sortrows( bins );
    sortflag = true;
end

%preallocate output
m = zeros(size(bins,1), numel(events));

%for each event vector, compute histogram
%and sort event vector if needed (will be slower)
%note that histc cannot be used since it does not support overlapping
%bins, something that sortedhist does support
for k=1:numel(events)
    if issorted(events{k})
        m(:,k) = sortedhist( events{k}, bins );
    else
        m(:,k) = sortedhist( sort(events{k}), bins );
    end
end

%transpose output, such that rows represent events and columns represent bins
m = m';

%convert histogram to count, binary or rate
switch options.method
 case 'count'
  %nothing to do here
  
 case 'binary'
  %convert counts to 0/1
  m( m>0 ) = 1;
  
 case 'rate'
  %convert counts to rate based on bin size
  m = bsxfun( @rdivide, m, diff(bins,1,2)');   
  
end

%if bins had to be sorted initially, unsort them here
if sortflag
    m = m(:,sidx);
end


