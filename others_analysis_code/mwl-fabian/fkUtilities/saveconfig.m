function saveconfig( name, c )
%SAVECONFIG save configuration
%
%  SAVECONFIG(filename, cfg) saves a configuration object or structure to
%  a file. The default path for configuration files can be set using
%  setconfigpath. If no default path exists or if the name arguments
%  starts with a '.' then the configuration file will be saved in the
%  current directory.
%
%  See also: configobj, loadconfig, setconfigpath
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<2 || ~ischar( name ) || numel(name)<1 || (name(1)=='.' && numel(name)==2)
  help(mfilename)
  return
end

if name(1)=='.'
  
  name = name(2:end);
  rootdir = pwd;
  
else

  if ~ispref('configuration', 'path')
      if isunix
          %default configuration path is $HOME
          setpref('configuration', 'path', getenv('HOME') );
      else
          error('saveconfig:invalidPath', 'No configuration path set')
      end
  end

  p = getpref( 'configuration' );
  
  if isempty( p ) || ~isfield( p, 'path' )
    rootdir = pwd;
  else
    rootdir = p.path;
  end
  
end

try
  c = configobj( c );
  write( c, fullfile( rootdir, [name '.cfg'] ) );
catch
  error('saveconfig:invalidConfiguration', ['Invalid configuration structure, ' ...
                      'or error writing file to disk'])
end
