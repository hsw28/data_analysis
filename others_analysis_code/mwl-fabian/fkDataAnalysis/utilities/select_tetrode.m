function idx = select_tetrode( tetrodes, varargin )
%SELECT_TETRODE selection of tetrodes
%
%  b=SELECT_TETRODE(tetrodes,feature1,criteria1,...) returns true
%  for tetrodes that meet all specified criteria. The following is
%  a list of supported features and their criteria that cna be
%  selected on:
%   id - vector of tetrode IDs
%   source -  vector of tetrode source numbers
%   source_name - regular expression string
%   sensor_name - regular expression string
%   file - regular expression string
%   name - regular expression string
%

%  Copyright 2006-2008 Fabian Kloosterman

%check arguments
if nargin<1
  help(mfilename)
  return
elseif nargin<2
  idx = (1:numel(tetrodes))';
  return
end

if mod( numel(varargin), 2 ) == 1
  error( 'select_tetrode:invalidArguments', ['Invalid tetrode selection ' ...
                      'filters'])
end

idx = true( numel(tetrodes), 1 );

%loop through all arguments
for k=1:2:numel(varargin)
  
  switch lower(varargin{k})
   case {'id', 'number'}
    idx = idx & ismember( [tetrodes.id]', varargin{k+1} );    
   case 'source'
    idx = idx & ismember( [tetrodes.source]', varargin{k+1} );
   case {'source_name', 'source name'}
    idx = idx & ~cellfun( 'isempty', regexp( {tetrodes.source_name}', ...
                                             varargin{k+1} ) );
   case {'sensor_name', 'sensor', 'sensor name'}
    idx = idx & ~cellfun( 'isempty', regexp( {tetrodes.sensor_name}', ...
                                             varargin{k+1} ) );    
   case {'file', 'file name'}
    idx = idx & ~cellfun( 'isempty', regexp( {tetrodes.waveform_file}', ...
                                             varargin{k+1} ) );    
   case {'name'}
    idx = idx & ~cellfun( 'isempty', regexp( {tetrodes.name}', ...
                                             varargin{k+1} ) );        
  end
  
end

%idx = find( idx );