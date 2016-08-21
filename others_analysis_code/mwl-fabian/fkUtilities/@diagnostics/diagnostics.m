function L = diagnostics( varargin )
%DIAGNOSTICS diagnostics constructor
%
%  d=DIAGNOSTICS() default constructor
%
%  d=DIAGNOSTICS(d) copy constructor
%
%  d=DIAGNOSTICS(filename) create a new instance of a diagnostics
%  object. If filename refers to an existing file than that file will be
%  read, otherwise an empty diagnostics object will be created.
%
%  A diagnostics object is a special kind of configobj, in which the
%  highest level sections are called logs. A diagnostics file can have
%  any number of logs and new logs can easily be added. A diagnostics
%  file has a 'created' key containing the date the file was created
%  and each log contains a 'log_date' key containing the date the log
%  was added.
%
%

%  Copyright 2005-2008 Fabian Kloosterman


if nargin == 0
  %default constructor
  L = struct( 'nlog', 0, 'filename', '', 'configobj', configobj() );
  L = class( L, 'diagnostics' );
  
elseif nargin==1 && isa( varargin{1}, 'diagnostics' )
  %copy constructor
  L = class( struct( varargin{1}, 'diagnostics' ) );
  
elseif nargin==1 && ischar( varargin{1} )
  
  if exist(varargin{1},'file') %read file
    L = struct('nlog', 0, 'filename', fullpath(varargin{1}), ...
               'configobj', configobj( fullpath(varargin{1}) ) );
    %is this a diagnostics file?
    s = sections( L.configobj );
    if ~isempty(s)
      R = regexp(s, '^log(?<n>[0-9]+)', 'names');
      R = horzcat( R{:} );
      if numel(R)~=numel(s)
        error('Diagnostics:diagnostics:invalidFile', ['Invalid diagnostics file: ' ...
                            L.filename])
      end
      L.nlog = max( str2num( char( {R.n} ) ) ); %#ok
    end      
    
  else
    %create new diagnostics file
    L = struct('nlog', 0, 'filename', varargin{1}, ...
               'configobj', configobj() );
    L.configobj.created = datestr( now );
  end
  
  L = class(L, 'diagnostics');
  
end
