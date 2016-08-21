function idx = select_eeg( eeg, varargin )
%SELECT_EEG selection of eeg signals
%
%  b=SELECT_EEG(eeg,feature1,criteria1,...) returns true for eeg
%  signals that meet all specified criteria. The following is a
%  list of supported features and criteria that can be selected on:
%   signal - vector of signal numbers
%   source - vector of source numbers
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
  idx = (1:numel(eeg))';
  return
end

if mod( numel(varargin), 2 ) == 1
  error( 'select_eeg:invalidArguments', ['Invalid eeg selection ' ...
                      'filters'])
end

idx = true( numel(eeg), 1 );

%loop through all arguments
for k=1:2:numel(varargin)
  
  switch lower(varargin{k})
   case 'signal'
    idx = idx & ismember( [eeg.signal]', varargin{k+1} );   
   case 'source'
    idx = idx & ismember( [eeg.source]', varargin{k+1} );
   case {'source_name', 'source name'}
    idx = idx & ~cellfun( 'isempty', regexp( {eeg.source_name}', ...
                                             varargin{k+1} ) );
   case {'sensor_name', 'sensor', 'sensor name'}
    idx = idx & ~cellfun( 'isempty', regexp( {eeg.sensor_name}', ...
                                             varargin{k+1} ) );    
   case {'file', 'file name'}
    idx = idx & ~cellfun( 'isempty', regexp( {eeg.file}', ...
                                             varargin{k+1} ) );    
   case {'name'}
    idx = idx & ~cellfun( 'isempty', regexp( {eeg.name}', ...
                                             varargin{k+1} ) );        
  end
  
end

%idx = find( idx );