function l=new_diagnostics_log( description, varargin )
%NEW_DIAGNOSTICS_LOG create standard diagnostics log
%
%  log=NEW_DIAGNOSTICS_LOG(description,argname1,argval1,...) creates a new
%  diagnostics log with the given description and arguments.
%

%  Copyright 2009 Fabian Kloosterman

try
    args = struct( varargin{:} );
catch
    error('new_diagnostics_log:invalidArgument', 'Invalid argument name/value pairs')
end

if nargin<1
    description = 'none';
elseif ~ischar(description)
    error('new_diagnostics_log:invalidArgument', 'Invalid description')
end

l = configobj();

l.status = 'incomplete';
l.description = description;

if evalin('caller', 'exist(''MODIFICATION_DATE'',''var'')')
  tmp = evalin('caller', 'MODIFICATION_DATE'); %#ok
else
  tmp = 'unknown'; %#ok
end

l.mfile.modification_date = tmp;

if evalin('caller', 'exist(''REVISION'',''var'')')
  tmp = evalin('caller', 'REVISION'); %#ok
else
  tmp = 'unknown'; %#ok
end

l.mfile.revision = tmp;

tmp = dbstack();

l.mfile = setcomment( l.mfile, ['version information for m-file: ' tmp(2).name] );

if ~isempty(fields(args))
    l.arguments = configobj(args);
end
