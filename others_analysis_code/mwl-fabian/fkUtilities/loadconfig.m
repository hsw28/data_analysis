function c = loadconfig( name )
%LOADCONFIG load configuration
%
%  c=LOADCONFIG(name) loads the specified configuration file and returns
%  a config object. The default path for configuration files can be
%  set using setconfigpath. If no default path exists or if the name
%  arguments starts with a '.' then the configuration file will be loaded
%  from the current directory.
%
%  See also: configobj, saveconfig, setconfigpath
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1 || ~ischar( name ) || numel(name)<1 || (name(1)=='.' && numel(name)==2)
  help(mfilename)
  return
end

if name(1)=='.'
  
  name = name(2:end);
  rootdir = pwd;
  
else

  p = getpref( 'configuration' );
  
  if isempty( p ) || ~isfield( p, 'path' )
    rootdir = pwd;
  else
    rootdir = p.path;
  end
  
end

try
  c = configobj( fullfile( rootdir, [name '.cfg'] ) );
catch
  error('loadconfig:invalidConfigFile', 'Does configuration file exist?')
end
