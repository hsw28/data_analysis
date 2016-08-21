function idx = select_cluster( clusters, varargin )
%SELECT_CLUSTER selection of clusters
%
%  b=SELECT_CLUSTER(clusters,feature1,criteria1,...) returns
%  true for clusters that meet all specified criteria. The
%  following is a list of supported features and their criteria
%  that can be selected on:
%   index - either 1) a vector of cluster numbers or 2) a vector
%           with the same number of elements as there are clusters,
%           where each non-zero element selects that cluster.
%   tetrode - vector of tetrode IDs
%   source - vector of cluster source numbers
%   source_name - regular expression string
%   sensor_name - regular expression string
%   rate - either scalar or 1x2 range vector (see INRANGE)
%   lratio - either scalar or 1x2 range vector (see INRANGE)
%   isolation_distance - either scalar or 1x2 range vector (see INRANGE)
%   quality - scalar, column vector, 4x1 matrix or 4x2 matrix that
%             specifies the ranges for fabian's subjective quality
%             measures.
%   width - either scalar or 1x2 range vector (see INRANGE)
%   
%

%  Copyright 2006-2008 Fabian Kloosterman


%check arguments
if nargin<1
  help(mfilename)
  return
elseif nargin<2
  idx = (1:numel(clusters))';
  return
end

if mod( numel(varargin), 2 ) == 1
  error( 'select_cluster:invalidArguments', ['Invalid cluster selection ' ...
                      'filters'])
end

idx = true( numel(clusters), 1 );

%loop through arguments
for k=1:2:numel(varargin)
  
  switch lower(varargin{k})
   case {'index', 'idx'}
    if numel(idx) == numel( varargin{k+1} )
      idx = idx & varargin{k+1}(:);
    else
      idx = idx & ismember( (1:numel(clusters))', varargin{k+1} );
    end
   case 'tetrode'
    idx = idx & ismember( [clusters.tetrode]', varargin{k+1} );
   case 'source'
    idx = idx & ismember( [clusters.source]', varargin{k+1} );
   case {'source_name', 'source name'}
    idx = idx & ~cellfun( 'isempty', regexp( {clusters.source_name}', ...
                                             varargin{k+1} ) );
   case {'sensor_name', 'sensor', 'sensor name'}
    idx = idx & ~cellfun( 'isempty', regexp( {clusters.sensor_name}', ...
                                             varargin{k+1} ) );    
   case 'rate'
    idx = idx & inrange( [clusters.rate]', varargin{k+1} );
   case 'lratio'
    idx = idx & inrange( [clusters.lratio]', varargin{k+1} );    
   case {'isolation_distance', 'iso_distance', 'isolation distance'}
    idx = idx & inrange( [clusters.iso_distance]', varargin{k+1} );    
   case {'subjective_quality', 'subjective quality', 'quality'}
    if size(varargin{k+1},1)==1
      varargin{k+1} = repmat( varargin{k+1}, 4, 1 );
    end
    tmp = vertcat( clusters.subjective_quality );
    idx = idx & inrange(tmp(:,1), varargin{k+1}(1,:)) & ...
          inrange(tmp(:,2), varargin{k+1}(2,:)) & ...
          inrange(tmp(:,3), varargin{k+1}(3,:)) & ...
          inrange(tmp(:,4), varargin{k+1}(4,:));
   case {'width'}
    idx = idx & inrange( [clusters.wave_width]', varargin{k+1} );
  end
  
end

%idx = find( idx );