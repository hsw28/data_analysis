function varargout = dirfun( varargin )
%DIRFUN apply function to directories recursively
%
%  DIRFCN(fcn) calls function for current working directory and every
%  subdirectory in it. The first argument to the function will be the
%  full path of the directory.
%
%  dirs=DIRFCN(fcn) returns a list of processed subdirectories.
%
%  [dirs,out1,out2,...]=DIRFCN(fcn) returns the outputs of the function.
%
%  [...]=DIRFCN(fcn,parm1,val1,...) specifies optional parameters. Valid
%  parameters are:
%   Path - root directory (default = '.')
%   Recurse - 0/1 recurse into subdirectories
%   MaxLevel - maximum recursion level (default=3)
%   RegExp - regular expression for directory selection
%   FullPath - 0/1 return full path
%   Argin - cell array of extra arguments for the function
%
%  See also FILEFUN
%

%  Copyright 2005-2008 Fabian Kloosterman

% options
args = struct('Recurse', 1, 'MaxLevel', 3, 'FullPath', ...
              0, 'ArgIn', {{}}, 'RegExp', '.*', 'Path', pwd );

%check input arguments
if nargin>=1 && isa( varargin{1}, 'function_handle' )
  fcn = varargin{1};
  args = parseArgs(varargin(2:end), args);  
else
  fcn = [];
  args = parseArgs(varargin, args);
end

if ~iscell(args.RegExp)
  args.RegExp = {args.RegExp};
end

nOut = nargout;

if ~isempty( fcn ) &&  ~isa( fcn, 'function_handle' )
  error('dirfun:invalidFunction', 'invalid function')
end

if (~isempty(fcn) && nOut > (nargout(fcn)+1) && nargout(fcn)>=0 ) || (isempty(fcn) && nOut>1)
  error('dirfun:invalidOutputs', 'Too many outputs')
end

varargout = cell(1, nOut);
dirout = cell(0,1);

if nOut>1
  tmp_out = cell(0, nOut-1); %#ok
end

rootdir = fullpath( args.Path );
s = strread( rootdir, '%s', 'delimiter', filesep);
p = s{end};
rootdir = filesep;
if numel(s)>1
  rootdir = fullfile(rootdir, s{1:end-1} );
end
do_recurse( p, 1 )

varargout{1} = dirout;

if nOut>1
  [varargout{2:end}] = uncat( 2, tmp_out );
end


  function do_recurse( p, level )
  %p should be a partial path (i.e. relative to rootdir)
  
  dir_name = strread( p, '%s', 'delimiter', filesep );
  if numel(dir_name)>0
    dir_name = dir_name{end};
  else
    dir_name = '';
  end
  
  %match current path to regular expression
  %if match call function
  if ~all( cellfun( 'isempty', regexp( dir_name, args.RegExp ) ) )

    %save dir path
    if args.FullPath
      dirout{end+1,1} = fullfile( rootdir, p );
    else
      dirout{end+1,1} = p;
    end
    
    %call function
    if ~isempty(fcn)
      if nOut>1
        try
          [tmp_out{end+1,:}] = fcn( fullfile( rootdir, p ), args.ArgIn{:} );
        catch
          [tmp_out{end+1,:}] = NaN;
          fprintf(['Error while calling function on: ' fullfile( ...
              rootdir, p ) '\n%s\n'], lasterr );
        end
      else
        try
          fcn( fullfile( rootdir, p ), args.ArgIn{:} ); %#ok
        catch
          fprintf(['Error while calling function on: ' fullfile( ...
              rootdir, p ) '\n%s\n'], lasterr );
        end
      end
    end    
  end

  
  %get list of subdirs
  %recurse
    
  %get list of directories
  dir_list = dir( fullfile( rootdir, p ) );

  %remove files and '.', '..'
  if ~isempty(dir_list)
    dir_list( [dir_list.isdir]==0 ) = [];
    dir_list( ismember( {dir_list.name}, {'.', '..'} ) ) = [];
  end
  
  %recurse down into subdirectories
  if args.Recurse && level<=args.MaxLevel
    
    for k=1:numel(dir_list)
      do_recurse( fullfile( p, dir_list(k).name ), level + 1 );
    end
    
  end
  
  end


end
