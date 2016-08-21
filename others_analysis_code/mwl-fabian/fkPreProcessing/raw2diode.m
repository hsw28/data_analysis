function varargout=raw2diode(rawpos,varargin)
%RAW2DIODE compute diode coordinates from raw position data
%
%  c=RAW2DIODE(rawpos) computes the coordinates of a single diode from a
%  struct array of raw position records.
%
%  c=RAW2DIODE(rawpos,parm1,val1,...) sets extra parameters. Valid
%  parameters include:
%   fs - sampling frequency (default=30 Hz)
%   maxdist - maximum pixel distance (default=5)
%
%  [c,stats]=RAW2DIODE(...) returns a structure with information about
%  the operation
%

%  Copyright 2007-2007 Fabian Kloosterman


%check input arguments
if nargin<1
  help(mfilename)
  return
end

options = struct( 'fs', 30, 'maxdist', 5);
options = parseArgs( varargin, options );

if ~isstruct(rawpos) || ...
      ~all( ismember( fieldnames(rawpos), {'timestamp', 'frame', 'nitems', 'pos'} ) ) || ...
      ~isstruct( rawpos.pos ) || ...
      ~all( ismember( fieldnames(rawpos.pos), {'x', 'y'} ) )
  error('raw2diode:invalidArguments', 'Invalid raw position structure')
end

%create stats structure
stats.nframes = numel( rawpos.nitems );
stats.fs = options.fs;
stats.maxdist = options.maxdist;

options.maxdist = options.maxdist.^2;
options.interval_threshold = 10000*1.5/options.fs;

diodepos = NaN( stats.nframes,2 );

pos = struct2cell( rawpos.pos );

idx = rawpos.nitems>1;

diodepos(idx,1) = cellfun( @(x) sum(double(x)), pos(1,idx));
diodepos(idx,2) = cellfun( @(x) sum(double(x)), pos(2,idx));

diodepos = bsxfun( @rdivide, diodepos, double(rawpos.nitems) );

%process each frame
for k=find( rawpos.nitems>2 )'
  
  %compute distance matrix
  tmp = double( [pos{1,k} pos{2,k}] );
  d = bsxfun(@minus,tmp(:,1), tmp(:,1)').^2 + bsxfun(@minus,tmp(:,2), tmp(:,2)').^2;
  
  if max(d(:))>options.maxdist
    %find groups of connected pixels
    groups = imglabel( tmp, options.maxdist./2 );
    if numel(groups)>1
      %if there is no previous valid coordinate then take the group with
      %the most pixels
      if k==1 || isnan(diodepos(k-1,1)) || ...
           diff(rawpos.timestamp([-1 0]+ k))>options.interval_threshold
        sz = cellfun( 'prodofsize', groups );
        [mx,mx] = max( sz ); %#ok
        diodepos(k,:) = mean( groups{mx} );
      else
        %compute distance between mean of groups and previous valid
        %coordinate and select group with smallest distance
        m = apply2cell(@mean, {1}, groups);
        [mx,mx] = min( sum(bsxfun(@minus, vertcat( m{:} ), diodepos(k-1,:) ).^2,2 )); %#ok
        diodepos(k,:) = m{mx};
      end
    else
      diodepos(k,:) = mean( groups{1} );
    end
  end
  
end

if nargout>0
  varargout{1} = diodepos;
end

if nargout>1
  varargout{2} = stats;
end

