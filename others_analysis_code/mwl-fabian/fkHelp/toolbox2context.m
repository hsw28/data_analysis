function toolbox2context( toolbox_path, toolbox_name, dest_path )
%TOOLBOX2CONTEXT generate a context help document from a toolbox
%
%  TOOLBOX2CONTEXT create a toolbox help document for the current
%  working directory
%
%  TOOLBOX2CONTEXT(path) create a help document for the toolbox in the
%  specified path
%
%  TOOLBOX2CONTEXT(path, name) specifies a custom name for the toolbox
%  (by default the name of the toolbox directory is used)
%
%  TOOLBOX2CONTEXT(path, name, destination_path) puts the resulting tex
%  file in the specified destination path (by default the file is saved
%  in <toolbox path>/tex)
%
%  Example
%    toolbox_path = '/myhome/mymatlab/mytoolbox';
%    toolbox2context( toolbox_path );
% 

%  Copyright 2005-2006 Fabian Kloosterman

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
  dest_path = fullfile( toolbox_path, 'tex' );
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
  

%start main toolbox tex file
main_tex = sprintf(['\\startcomponent %s\n\n\\project MWLBooks\n\n\\product ' ...
                    'MatlabAnalysis\n\n'], charreplace_context(toolbox_name));
main_tex = [main_tex sprintf('\\doifundefined {helpitem}\n{\\def\\helpitem#1{\\subsubsection{#1}}}\n\n')];
main_tex = [main_tex sprintf('\\doifundefined {parameter}\n{\\definedescription[parameter]}\n\n')];
main_tex = [main_tex sprintf('\\starttext\n\n\\chapter{%s}\n\n', charreplace_context(toolbox_name) )];

if ~isempty(ridx)
  main_tex = [main_tex sprintf(['\\startalignment[middle]\n\\it{version %s ' ...
                      '(%s)}\n\\stopalignment\n\n'], charreplace_context(r{ridx}.version), ...
                               charreplace_context(r{ridx}.date))];
end

main_tex = [main_tex sprintf('\\placecontent\n\n\\section{public functions}\n\n')];

%build functions
for k=1:numel(toolbox_functions.m)
  
  main_tex = [main_tex parse_help( fullfile( toolbox_path, ...
                                              [toolbox_functions.m{k} '.m'] ...
                                              ), 'context') ];
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
  main_tex = [main_tex class2context( toolbox_path, toolbox_functions.classes{k}, ...
                                      hidden_class_methods )];
end


main_tex = [main_tex sprintf('\n\\stoptext\n\n\\stopcomponent\n')];

fid = fopen( fullfile(dest_path, [toolbox_name, '.tex']), 'w');
if fid<0
    warning('fkHelp:toolbox2context:invalidFile', ['Unable to write to ' ...
                        'file ' fullfile(dest_path, [toolbox_name, '.tex']) ...
                        '.']);
else
  fprintf(fid, '%s', main_tex);
  fclose(fid);
end

cd(old_path);