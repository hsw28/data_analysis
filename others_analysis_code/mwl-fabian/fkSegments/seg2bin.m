function [bins,nbins]=seg2bin(seg,varargin)
%SEG2BIN divide segment into bins
%
%  bins=SEG2BIN(seg) divide segment(s) into 10 equal-sized bins.
%
%  bins=SEG2BIN(seg,parm1,val1,...) set optional parameters. Valid
%  parameters are:
%   method - one of 'binsize', 'nbins', 'nevents'
%   binsize - bin size
%   nbins - number of bins
%   overlap - fraction of overlap between bins
%   minbinsize - minimum bin size
%   minevents - minimum number of events in a bin
%   events - event vector
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<1
  help(mfilename)
  return
end

if ~isnumeric(seg) || ~ndims(seg)==2 || size(seg,2)~=2
  error('seg2bin:invalidArgument', 'Invalid segments')
end

if size(seg,1)<1
  bins = [];
  return
end

options = struct('method', 'binsize', ...
                 'binsize', [], ...
                 'nbins', 10, ...
                 'overlap', 0, ...
                 'minbinsize', 0, ...
                 'minevents', 10, ...
                 'events', []);

options = parseArgs( varargin, options);

switch options.method
 case 'binsize'
  if isempty(options.binsize)
    options.binsize = diff(seg,1,2)./10;
    nbins = ones(size(seg,1),1).*10;
  elseif ~isnumeric(options.binsize) || ~isscalar(options.binsize)
    error('seg2bin:invalidArgument', 'Invalid bin size')
  else
    %compute number of bins
    nbins = round( ( diff(seg,1,2) - options.overlap.*options.binsize ) ./ ((1-options.overlap).*options.binsize) );
  end
  
  %determine bin edges
  bins = zeros(0,2);
  if options.overlap==0
    for k=1:numel(nbins)
      tmp = (0:nbins(k))'.*options.binsize;
      bins = vertcat( bins, seg(k,1)+[tmp(1:end-1) tmp(2:end)]);
    end
  else
    for k=1:numel(nbins)
      tmp = (0:(nbins(k)-1))'.*(1-options.overlap).*options.binsize + seg(k,1);
      bins = vertcat( bins, [tmp tmp+options.binsize]);
    end
  end  
  
  
 case 'nbins'
  if ~isnumeric(options.nbins) || ~isscalar(options.nbins) || ...
        options.nbins<1
    error('seg2bin:invalidArgument', 'Invalid number of bins')
  end
  
  %compute binsize
  nbins = options.nbins .* ones(size(seg,1),1);
  binsize = diff(seg,1,2) ./ ( nbins.*( 1-options.overlap ) + options.overlap );

  %adjust number of bins if bin size is smaller than minimum allowed
  idx = binsize<options.minbinsize;
  if any(idx)
      binsize(idx) = options.minbinsize;
      nbins(idx) = floor( ( diff(seg(idx,:),1,2) - options.overlap.*binsize(idx) ) ./ ((1-options.overlap).*binsize(idx)) );
  end
  
  %determine bin edges
  bins = zeros(0,2);
  for k=1:numel(nbins)
    tmp = (0:(nbins(k)-1))'.*(1-options.overlap).*binsize(k) + seg(k,1);
    bins = vertcat( bins, [tmp tmp+binsize(k)]);  
  end
  
 case 'nevents'
  %check events option
  if isempty(options.events)
    error('seg2bin:invalidEvents', 'Invalid events vector')
  elseif iscell(options.events)
    options.events = sort(vertcat( options.events{:} ));
  end  

  bins = zeros(0,2);
  
  for k=1:size(seg,1)
    
    %find all events in window
    start_event = find( options.events>=seg(k,1), 1 );
    end_event = find( options.events<=seg(k,end), 1, 'last');
    
    n_events = end_event - start_event + 1;

    start_time = seg(k,1);

    binedges=[];
    
    %step through events and determine the bin windows
    while start_event<=end_event
  
      %find n next events 
      ii = find( options.events( start_event:end_event ) <= seg(k,end), options.minevents );
    
      %calculate binsize
      if ii(end)+start_event-1==n_events
        binsize = seg(k,end)-start_time;
        %correct if bin size < minimum allowed
        if binsize>=options.minbinsize
          binedges(end+1,1:2) = [start_time start_time+binsize];
        end
        start_event = end_event+1;
      else
        binsize = mean( options.events(ii(end)+start_event+[-1 0]) ) - start_time;
        %correct if bin size < minimum allowed
        binsize = max( options.minbinsize, binsize );
        %determine bin edges
        binedges(end+1,1:2) = [start_time start_time+binsize];
        %update stepping vars
        start_time = start_time + (1-options.overlap).*binsize;
        start_event = find( options.events>=start_time, 1 );
      end
      
    end  
    
    nbins(k) = numel(binedges)-1;
    
    bins = vertcat( bins, binedges );
    
  end
  
end
