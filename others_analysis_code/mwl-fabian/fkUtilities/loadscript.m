function v_______ = loadscript( rootdir, filename )
%LOADSCRIPT load parameters from .m file
%
%  v=LOADSCRIPT(file) this will evaluate the given file and return
%    the variables created by the script. If the script defines a
%    "parent" variable which points to a valid script file, then
%    that parent file is loaded first and combined with the
%    variables defined in the child script.
%
%  v=LOADSCRIPT(rootdir,file) this will use the script file located
%    in the given root directory.
%

%  Copyright 2009 Fabian Kloosterman


%check input arguments
if nargin==1
    filename = fullpath( rootdir );
elseif nargin==2
    filename = fullpath( fullfile( rootdir, filename ) );
else
    error('loadscript:invalidArguments', 'Invalid script')
end

%check if file exists, append .m if necessary
if ~exist( filename, 'file' ) || isdir( filename )
    error('loadscript:invalidArgument', 'Invalid file name')
elseif isempty( dir( filename ) ) %user specified .m file without the extension
    filename = [filename, '.m'];
end 

%read complete file
%(we could use the 'run' function, but that only works for files with .m extension)
fid = fopen( filename );
z_______ = fread( fid, '*char' ); %use variable name unlikely to be used in script
fid = fclose(fid);

%clear created variables
filename_______ = filename;
clear filename rootdir fid

%evaluate text
eval( z_______ );

%clear text variable
clear z_______

%get variables created in current workspace
vars_______ = who();

if ismember( 'parent', vars_______ )
    
    oldpath = pwd;
    newpath = fileparts( filename_______ );
    cd(newpath);
    
    try
        parent_______ = loadscript( fullpath( parent ) );
    catch
        parent_______ = struct();
    end
    
    cd(oldpath);
    
else
    
    parent_______ = struct();
    
end

vars_______(ismember(vars_______,{'filename_______', 'parent'})) = [];

%assign variables to output variable
if isempty(vars_______)
    v_______ = struct();
else
    for k=1:numel(vars_______)
        eval( ['v_______.(vars_______{k}) = ' vars_______{k} ';'] );
    end
end

v_______ = struct_union( parent_______, v_______ );
