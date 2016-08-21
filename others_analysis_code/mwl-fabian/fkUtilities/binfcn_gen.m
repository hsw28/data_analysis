function f = binfcn_gen( option, varargin )
%BINFCN_GEN generator of binning functions
%
%  f=BINFCN_GEN(fcn_type,...) This function generates a function handle
%  for a binning function. Arguments two and up are passed on to the
%  binning function. The signature for a binning function is: binedges =
%  fcn( time_window, ... ), where binedges is a nx2 matrix of bin
%  edges. The argument fcn_type is one of:
%   binsize - subdivide time window in equal size bins. Valid options:
%             'Overlap' (default = 0), 'BinSize' (required)
%   nbins   - subdivide time window in fixed number of bins. Valid
%             options: 'Overlap' (default = 0), 'MinBinSize' (default =
%             0), 'NBins' (required)
%   nevents - subdivide time window into smaller windows that contain an
%             equal number of events. Valid options: 'Overlap' (default =
%             0), 'MinBinSize' (default = 0), 'MinEvents' (default = 10),
%             'Events' (required)
%  Explanation of binning function options:
%   Overlap - fraction of overlap between adjacent bins
%   BinSize - bin size
%   NBins - number of bins
%   MinBinSize - minimum bin size, other parameter will be adjusted to
%                meet this requirement
%   MinEvents - minimum number of events in a bin
%   Events - column vector or cell array of column vectors with event
%            times
%
%


%  Copyright 2005-2008 Fabian Kloosterman


args = varargin;

switch option
    
 case 'binsize'
  f = @(timewnd, varargin) fixed_binsize( timewnd, args{:}, varargin{:});
 case 'nbins'
  f = @(timewnd, varargin) fixed_nbins( timewnd, args{:}, varargin{:});
 case 'nevents'
  f = @(timewnd, varargin) adaptive_nspikes( timewnd, args{:}, varargin{:});        
 otherwise
  error('fkUtilities:binfcn_gen:invalidArguments', ['Unknown function ' ...
                      'type'])
  
end


%---BINNING FUNCTIONS---

function [binedges, nbins] = fixed_binsize( varargin )
%FIXED_BINSIZE

options = struct( 'overlap', 0, 'binsize', [] );

[timewnd, options] = check_params( options, varargin{:} );

if isempty( options.binsize ) || options.binsize<=0
  error('fixed_binsize:invalidBinSize', 'Invalid bin size')
end

%compute number of bins
nbins = round( ( diff(timewnd,1,2) - options.overlap.*options.binsize ) ./ ((1-options.overlap).*options.binsize) );

%determine bin edges
binedges = zeros(0,2);
if options.overlap==0
  for k=1:numel(nbins)
    tmp = (0:nbins(k))'.*options.binsize;
    binedges = vertcat( binedges, timewnd(k,1)+[tmp(1:end-1) tmp(2:end)]);
  end
else
  for k=1:numel(nbins)
    tmp = (0:(nbins(k)-1))'.*(1-options.overlap).*options.binsize + timewnd(k,1);
    binedges = vertcat( binedges, [tmp tmp+options.binsize]);
  end
end



function binedges = fixed_nbins( varargin )
%FIXED_NBINS

options = struct( 'overlap', 0, 'minbinsize', 0, 'nbins', [] );

[timewnd, options] = check_params( options, varargin{:} );

if isempty(options.nbins) || options.nbins<=0
  error('fixed_nbins:invalidNBins', 'Invalid number of bins')
end

%compute binsize
nbins = options.nbins;
binsize = diff(timewnd) ./ ( nbins.*( 1-options.overlap ) + options.overlap );

%adjust number of bins if bin size is smaller than minimum allowed
if binsize<options.minbinsize
    binsize = options.minbinsize;
    nbins = floor( ( diff(timewnd) - options.overlap.*binsize ) ./ ((1-options.overlap).*binsize) );
end

%determine bin edges
binedges = (0:(nbins-1))'.*(1-options.overlap).*binsize + timewnd(1);
binedges = [binedges binedges+binsize];


function binedges = adaptive_nspikes( varargin )

options = struct( 'overlap', 0, 'minbinsize', 0, 'minevents', 10, 'events', [] );

[timewnd, options] = check_params( options, varargin{:} );

%check events option
if isempty(options.events)
  error('adaptive_nspikes:invalidEvents', 'Invalid events vector')
elseif iscell(options.events)
  options.events = sort(vertcat( options.events{:} ));
end

%find all events in window
start_event = find( options.events>=timewnd(1), 1 );
end_event = find( options.events<=timewnd(end), 1, 'last');

n_events = end_event - start_event + 1;

binedges = [];

start_time = timewnd(1);

%step through events and determine the bin windows
while start_event<=end_event
  
    %find n next events 
    ii = find( options.events( start_event:end_event ) <= timewnd(end), options.minevents );
    
    %calculate binsize
    if ii(end)+start_event-1==n_events
        binsize = timewnd(end)-start_time;
        %correct if bin size < minimum allowed
        if binsize>=options.minbinsize
            binedges(end+1,1:2) = [start_time start_time+binsize];
        end
        start_event = end_event+1;
    else
        binsize = mean( options.Events(ii(end)+start_event+[-1 0]) ) - start_time;
        %correct if bin size < minimum allowed
        binsize = max( options.minbinsize, binsize );
        %determine bin edges
        binedges(end+1,1:2) = [start_time start_time+binsize];
        %update stepping vars
        start_time = start_time + (1-options.overlap).*binsize;
        start_event = find( options.events>=start_time, 1 );
    end
    
end



function [timewnd, options] = check_params( options, timewnd, varargin )
%CHECK_PARAMS

if nargin<2
  error('fkUtilities:binfcn_gen:invalidArguments', 'Need at least one argument')
end

if ~isnumeric(timewnd) || size(timewnd,2)~=2
  error('fkUtilities:binfcn_gen:invalidArguments', 'Invalid time window argument')
end

[options, other, remainder] = parseArgs( varargin, options ); %#ok
