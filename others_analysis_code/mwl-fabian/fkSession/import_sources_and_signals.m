function [sources, signals] = import_sources_and_signals( rootdir )
%IMPORT_SOURCES_AND_SIGNALS import sources and signals
%
%  [sources,signals]=IMPORT_SOURCES_AND_SIGNALS(rootdir) import sources
%  and signals data files from root directory
%

%  Copyright 2007-2008 Fabian Kloosterman

VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end

sources = [];
signals = [];

if exist( fullfile( rootdir, 'sources.dat' ), 'file' )
  fid = mwlopen( fullfile( rootdir, 'sources.dat') );
  sources = load( fid );
  verbosemsg(['Imported ' fullfile( rootdir, 'sources.dat')])
end

if exist( fullfile( rootdir, 'signals.dat' ), 'file' )
  fid = mwlopen( fullfile( rootdir, 'signals.dat') );
  signals = load( fid );
  verbosemsg(['Imported ' fullfile( rootdir, 'signals.dat')])
end