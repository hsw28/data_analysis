function export_sources_and_signals( rootdir, sources, signals )
%EXPORT_SOURCES_AND_SIGNALS export sources and signals
%
%  EXPORT_SOURCES_AND_SIGNALS(rootdir,sources,signals) exports sources
%  and signals data to rootdir
%

%  Copyright 2007-2008 Fabian Kloosterman

VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end

if nargin>1 && ~isempty(sources) && isstruct(sources) && ...
      all(ismember(fieldnames(sources),{'id','sensor','name','description'}))

  flds = mwlfield( {'id', 'name', 'sensor', 'description'}, {'int16', ...
                      'string', 'string', 'string'}, {1 20 20 100} );
  
  mwlcreate( fullfile( rootdir, 'sources.dat' ), 'fixedrecord', 'Fields', flds, 'FileFormat', 'ascii', 'Data', sources, 'Mode', 'overwrite');  

end

if nargin>2 && ~isempty(signals) && isstruct(signals) && ...
      all(ismember(fieldnames(signals),{'id','name','type','source', ...
                      'refsource','file','channel'}))

  flds = mwlfield( {'id', 'name', 'type', 'source', 'refsource', 'file', 'channel'}, {'int16', 'string', 'string', 'int16', 'int16', 'string', 'int16'}, {1 20 10 1 1 100 1} );

  mwlcreate( fullfile( rootdir, 'signals.dat' ), 'fixedrecord', 'Fields', flds, 'FileFormat', 'ascii', 'Data', signals, 'Mode', 'overwrite');
  
end
