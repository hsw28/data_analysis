function p = fullpath(rel_path)
%FULLPATH get full path for a given relative path
%
%  p=FULLPATH(relpath) returns the full path given a relative path.
%
%  Example
%    cd /home/mydata
%    fullpath( 'data.dat' ) %returns /home/mydata/data.dat
%    fullpath( '../otherdata/data.dat' ) %returns /home/otherdata/data.dat
%


%  Copyright 2005-2008 Fabian Kloosterman


%return current directory by default
if nargin<1 || isempty(rel_path) || strcmp(rel_path, '.')
    p = pwd;
    return
end


%try to find path
try
    path_type = exist(rel_path, 'file');
    old_path = pwd;
    if path_type==7 %it's a directory
        cd(rel_path);
        p = pwd;
    elseif path_type==2 || path_type==3 || path_type==4 || path_type==6  %file
        [pathstr, name, ext] = fileparts(rel_path);
        if ~isempty(pathstr)
            cd(pathstr);
        end
        p = fullfile(pwd, [name ext]);
    else
        error('Invalid path')
    end

    cd(old_path);
catch
    error('fullpath:invalidPath', ['Unable to get full path - does path ' rel_path ' exist?'])
end
