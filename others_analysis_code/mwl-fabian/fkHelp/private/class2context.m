function body = class2context( rootdir, class_name, hidden_class_methods)
%CLASS2CONTEXT

CR = sprintf('\n');

%find base class, single inheritance only!
class_struct = struct( eval(class_name) );
fn = fieldnames( class_struct );
if isobject( class_struct.(fn{end}) )
  base_class = class_struct.(fn{end});
  base_methods = setdiff( methods(base_class), hidden_class_methods );
  base_class = class(base_class);
else
  base_class = '';
  base_methods = {};
end

class_methods = sort( setdiff( methods( eval(class_name) ), ...
                         hidden_class_methods) );

body = ['\section{@' charreplace_context(class_name) ' (class)}' CR CR];

%body = [body sprintf('\\subsection{base class}\n\n')];

if ~isempty(base_class)
  
  body = [body 'The base class of this class is ' charreplace_context(base_class) '.' CR];

  if ~isempty(base_methods)
    body = [body 'The following methods are inherited from ' ...
            charreplace_context(base_class) ':' CR CR];
    body = [body '\startitemize[columns,three][symbol=4,inbetween=\nowhitespace,before=\nowhitespace]' CR ];
    for k=1:numel(base_methods)
      body = [body '\item ' charreplace_context( base_methods{k} ) CR];
    end
    body = [body '\stopitemize' CR CR];
  else
    body = [body 'There are no inherited methods.' CR CR];
  end
  
else
  
  body = [body 'This class has no base class.' CR CR];
  
end

%make sure to process constructor first
constructor_idx = find( strcmp( class_name, class_methods ) );
if isempty(constructor_idx)
  %not a very useful class!
else
  %put constructor at top of the list
  class_methods = class_methods( [ constructor_idx ...
                      setdiff(1:numel(class_methods), constructor_idx)] );
end


%build methods
for k=1:numel(class_methods)
  %fid = fopen( fullfile( dest_path, [class_name '_' class_methods{k} '.tex'] ), 'w');
  %if fid<0
  %  warning('fkHelp:class2context:invalidFile', ['Unable to write to ' ...
  %                      'file ' fullfile( dest_path, [toolbox_functions.m{k} ...
  %                      '.tex']) '.' ]); 
  %  continue;
  %end
  %fprintf( fid, '%s', parse_help2( fullfile( rootdir, ['@'class_name], ...
  %                                           [class_methods{k} '.m'] ...
  %                                           ), 'context') );
  %fclose(fid);
  
  body = [body  parse_help( fullfile( rootdir, ['@' class_name], ...
                                       [class_methods{k} '.m'] ...
                                       ), 'context')];
end

