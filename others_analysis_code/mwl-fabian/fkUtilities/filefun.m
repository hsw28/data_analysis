function varargout = filefun( varargin )
%FILEFUN apply function to files recursivley
%
%  FILEFUN(fcn) calls function for every file in current working
%  directory. The signature of the function should be:
%  [out1,out2,...]=fcn(path,file,level,...)
%
%  files=FILEFUN(fcn) returns a list of processed files.
%
%  [files,out1,out2,...]=FILEFCN(fcn) returns the outputs of the
%  function.
%
%  [...]=FILEFUN(fcn,parm1,val1,...) specifies optional parameters. Valid
%  parameters are:
%   Path - root directory (default = '.');
%   Recurse - 0/1 recurse into subdirectories
%   MaxLevel - maximum recursion level (default = Inf)
%   Mask - wildcard mask for file listing
%   RegExp - regular expression(s) for file selection
%   FullPath - 0/1 return filename or full path to file
%   Argin - cell array of extra arguments for the function
%
%  See also DIRFUN
%

%  Copyright 2005-2008 Fabian Kloosterman

% options
args = struct('Recurse', 1, 'MaxLevel', Inf, 'Mask', '*', 'FullPath', ...
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
  error('filefun:invalidFunction', 'invalid function')
end

if (~isempty(fcn) && nOut > (nargout(fcn)+1) ) || (isempty(fcn) && nOut>1)
  error('filefun:invalidOutputs', 'Too many outputs')
end


varargout = cell(1, nOut);
fileout = cell(0,1);

if nOut>1
  tmp_out = cell(0, nOut-1); %#ok
end

do_recurse( args.Path, 1 )

varargout{1} = fileout;

if nOut>1
  [varargout{2:end}] = uncat( 2, tmp_out );
end


  function do_recurse( p, level )
  
  %get list of files
  file_list = dir( fullfile( p, args.Mask ) );

  %remove directories
  if ~isempty(file_list)
    file_list( [file_list.isdir]==1 ) = [];
  end
  
  for k=1:numel(file_list)
    
    %check if file is matched by one of the regular expressions
    if all( cellfun( 'isempty', regexp( file_list(k).name, args.RegExp ) ) )
      continue
    end
    
    %save file path
    if args.FullPath
      fileout{end+1,1} = fullpath( fullfile( p, file_list(k).name ) );
    else
      fileout{end+1,1} = file_list(k).name;
    end
    
    %call function
    if ~isempty(fcn)
      if nOut>1
        try
          [tmp_out{end+1,:}] = fcn( fullpath(p),  file_list(k).name, level, ...
                                    args.ArgIn{:} );
        catch
          [tmp_out{end+1,:}] = NaN;
          fprintf(['Error while calling function on: ' fullpath( fullfile( ...
              p, file_list(k).name ) ) '\n%s\n'], lasterr );
        end
      else
        try
          fcn( fullpath(p), file_list(k).name, level, args.ArgIn{:} ); %#ok
        catch
          fprintf(['Error while calling function on: ' fullpath( fullfile( ...
              p, file_list(k).name ) ) '\n%s\n'], lasterr );
        end
      end
    end
    
  end
  
  %recurse down into subdirectories
  if args.Recurse && level<=args.MaxLevel
    
    %find directories
    dir_list  = dir( p );
    dir_list( [dir_list.isdir]==0 ) = [];
    dir_list( ismember( {dir_list.name}, {'.', '..'} ) ) = [];
    
    for k=1:numel(dir_list)
      do_recurse( fullfile( p, dir_list(k).name ), level + 1 );
    end
    
  end
  
  end


end
