function toolbox2rst( toolbox_path, toolbox_name, dest_path)
%TOOLBOX2RST generate a reStructuredText document from a toolbox
%
%  TOOLBOX2RST create a toolbox help document for the current
%  working directory
%
%  TOOLBOX2RST(path) create a help document for the toolbox in the
%  specified path
%
%  TOOLBOX2RST(path, name) specifies a custom name for the toolbox
%  (by default the name of the toolbox directory is used)
%
%  TOOLBOX2RST(path, name, destination_path) puts the resulting rst
%  file in the specified destination path (by default the file is saved
%  in <toolbox path>/rst)
%
%  Example
%    toolbox_path = '/myhome/mymatlab/mytoolbox';
%    toolbox2rst( toolbox_path );
% 

%  Copyright 2009-2009 Fabian Kloosterman

if nargin<1
  toolbox_path = pwd;
end

%set path delimiter
if isunix
  delimiter = '/';
else
  delimiter = '\\';
end

%change to toolbox path
old_path = pwd;
cd(toolbox_path);
toolbox_path = pwd;

%find toolbox name if not provided
if nargin<2 || isempty(toolbox_name)
  toolbox_name = pwd;
  toolbox_name = strread(toolbox_name, '%s', 'delimiter', delimiter);
  toolbox_name = toolbox_name{end};
end

if nargin<3 || isempty(dest_path)
  dest_path = fullfile( toolbox_path, 'rst' );
end
[success,msg,msgid]=mkdir( dest_path ); %#ok

%get functions and classes
hidden_functions = {'makesources', 'contents'};
hidden_class_methods = union(hidden_functions, {'set', 'get', 'subsref', ...
                    'subsasgn', 'end', 'subsindex', 'Contents', 'schema'});

toolbox_functions = what( toolbox_path );
toolbox_functions.m = sort( strrep( toolbox_functions.m, '.m', '') );

toolbox_functions.m( ismember( lower(toolbox_functions.m), hidden_functions) ) = [];

%get version from Contents.m
contents = textread(fullfile(toolbox_path, 'Contents.m'),'%s','delimiter','\n','whitespace','');
pat = 'Version (?<version>[\w.]+) (?<date>[\w-]+)';
r = regexp(contents,pat,'names');
ridx = find( ~cellfun('isempty', r), 1, 'first' );

%start main toolbox rst file
hdr = toolbox_name;

main_rst = sprintf( '%s\n%s\n\n', hdr, repmat('=',1,numel(hdr)) );

if ~isempty(ridx)
    main_rst = [main_rst sprintf('*The current version of this toolbox is: %s (%s)*\n\n', r{ridx}.version, r{ridx}.date)];
end

main_rst = [main_rst sprintf('%s\n%s\n\n', 'public functions', '----------------')];

%build functions
for k=1:numel(toolbox_functions.m)
  
  main_rst = [main_rst parse_help( fullfile( toolbox_path, ...
                                   [toolbox_functions.m{k} '.m'] ...
                                    ), 'rst') ];
end

toolbox_functions.classes = sort( toolbox_functions.classes );

%find classes vs packages
ispkg = false(numel(toolbox_functions.classes),1);
for k=1:numel(toolbox_functions.classes)
  ispkg(k) = ~isempty( findpackage(toolbox_functions.classes{k} ) );
end

toolbox_functions.classes = toolbox_functions.classes(~ispkg);

%skip packages
%build classic classes only 
for k=1:numel(toolbox_functions.classes)
  main_rst = [main_rst class2rst( toolbox_path, toolbox_functions.classes{k}, ...
                                      hidden_class_methods )];
end


fid = fopen( fullfile(dest_path, [toolbox_name, '.rst']), 'w');
if fid<0
    warning('fkHelp:toolbox2rst:invalidFile', ['Unable to write to ' ...
                        'file ' fullfile(dest_path, [toolbox_name, '.rst']) ...
                        '.']);
else
  fprintf(fid, '%s', main_rst);
  fclose(fid);
end

cd(old_path);