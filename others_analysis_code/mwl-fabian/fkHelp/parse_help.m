function body = parse_help( mfile, target)
%PARSE_HELP parse m-file help
%
%  PARSE_HELP(mfile) parses the help in the specified m-file to html
%  code.
%
%  PARSE_HELP(mfile, target) parses the help to the specified target
%  ('html' or 'context' or 'rst').
%
%  A m-file help section can optinally start with a H1 line, which should
%  have the following format: %FUNCTION_IN_CAPS synopsis
%  
%  The parser will divide the help into paragraphs, which start with an
%  empty line, followed by a line of text with 2 or less spaces
%  between the % and the start of the text (i.e. an indentation <= 2).
%
%  Syntax paragraphs are special paragraphs that define a particular way
%  of calling the m-file function. The first line of a syntax paragraph
%  should contain the complete syntax, examples are:
%   1. FUNCTION
%   2. FUNCTION ARG1
%   3. outputs=FUNCTION
%   4. FUNCTION(inputs)
%   5. [out1, out2]=FUNCTION(arg1, arg2)
%  The rest of the paragraph may contains additional text to explain the
%  syntax in more detail.
%
%  Two other special paragraph types exist: examples and see also. The
%  first line of an example paragraph should start with 'example' or
%  'Example'. The remainder of the lines will be output unmodified. There
%  can be multiple example paragraphs. A see also paragraph start with
%  the words 'See also' or 'see also' followed by a space or semi-colon
%  and a list of space or comma separated function names. Only one see
%  also paragraph is allowed.
%
%  The parser is able to recognize enumerated lists, definition lists and
%  tables in paragraphs. An item in an enumerated list starts with a
%  number followed by a period and a space. All following lines that have
%  at least the same amount of identation as the first line are included
%  in the list item text. Thus, to continue a paragraph after a list, the
%  list has to be indented.
%
%  An item in a definition list starts with a single word followed by a
%  space, a dash and another space. The text that follows and any
%  following lines are part of the definition text. For example:
%   Alpha - the first letter of the Greek alphabet
%   Omega - the last letter of the Greek alphabet. The character that
%   represents omega is also used in physics to indicate the units for
%   electrical resistance (Ohm).
%
%  Simple tables can be created. A single line holds a single row in a
%  table. Table cells are separated by '|'. Each table row should start
%  and end with '|'. If the first row is followed by a line of just
%  dashes, then it will become the table header. For example:
%  | Column 1 | Column 2 | Column 3 |
%  ----------------------------------
%  |  (1,1)   |  (1,2)   |  (1,3)   |
%  |  (2,1)   |  (2,2)   |  (2,3)   |
%
%  If the target is 'html' then the function returns html code, but
%  without any <html> or <body> tags.
%

%  Copyright 2005-2007 Fabian Kloosterman

CR = sprintf('\n');

if nargin<2
  target = 'html';
end

body = '';

[file_path, fcn, file_extension] = fileparts( mfile ); %#ok

start_out( fcn, target );

%read m-file
mtext = textread( mfile, '%s', 'delimiter', '\n', 'whitespace', '');

%extract help section
comments = strmatch('%', strtrim( mtext ) ); %#ok

if isempty(comments)
  return
end

last_comment = find(diff(comments)~=1);
if isempty(last_comment)
    last_comment = numel(comments);
end

mtext = mtext( comments(1):comments(last_comment) );

if strcmp(target, 'html')
  mtext = code2html(mtext);
end

nlines = numel(mtext);

if nlines==0
  return
end

fcn = upper(fcn);

%regular expressions
r_indent = '^%(?<indent>[ ]*)';
r_fcn = ['^(\[.*\][ ]*=[ ]*|[a-zA-Z][a-zA-Z0-9_]*[ ]*=[ ]*)?' fcn '(\([^\(]*\)| ' ...
         '[A-Z][A-Z0-9_]*)?(?<remainder>\s+.*)?$'];
r_h1 = ['^%' fcn '(?<synopsis>.*)?'];
r_empty = '^%\s*$';
r_seealso = '^(S|s)ee also([ ]|:)(?<remainder>.*)';
r_def = '^(?<name>[a-zA-Z0-9_])+ [-] (?<item>.*)';
r_list = '^[0-9]+\. (?<item>.*)';
r_example = '^(E|e)xample';
r_table_line = '^[|].*[|]$';
r_table = '(?<=[|])(?<cell>[^|]*)(?=[|])';
r_table_divider = '^[-]+$';

%first line is H1 line?
rout = regexp( mtext{1}, r_h1, 'names' );
if ~isempty(rout)
  synopsis_out( strtrim(rout.synopsis), target );
  mtext(1)=[];
end

%break help into paragraphs, i.e. blocks of text with first line indented
%<= 2 spaces, followed by empty lines and >2 indented lines. The first
%line after an empty line with <=2 indent starts a new paragraph

%which lines are empty?
rout = regexp( mtext, r_empty );
empty_lines = ~cellfun( 'isempty', rout );

if isempty(rout)
  return
end

%remove multiple empty lines
idx = diff( [1; empty_lines] ) == 0 & empty_lines==1;
mtext(idx) = [];
empty_lines(idx) = [];

%remove empty lines at end
%startline = find( empty_lines==0, 1, 'first');
idx = find( empty_lines==0, 1, 'last' )+1;
mtext(idx:end) = [];
empty_lines(idx:end) = [];

if isempty(mtext) %no help
  return
end

%find indentation
rout = regexp( mtext, r_indent, 'names' );
rout = vertcat( rout{:} );
indent = cellfun( 'prodofsize', {rout.indent} )';

%remove empty lines inside paragraphs
%i.e. indent before empty line>2 and indent after empty line <=2
%idx = find(empty_lines(2:(end-1))==1 & indent(1:(end-2))>2 & indent(3:end)<=2)+1;
%mtext(idx)=[];
%empty_lines(idx)=[];
%indent(idx)=[];

%trim indents
mtext = regexprep( mtext, r_indent, '');

%separate the paragraphs
idx = find(empty_lines(1:end-1)==1 & indent(2:end)<=2);
par_idx = [ [1;idx(:)+1] [idx(:)-1;numel(mtext)] ];

syntax = {};
%loop through all paragraphs to find syntaxes
for k=1:size(par_idx,1)
  
  %function syntax?
  rout = regexp( mtext{ par_idx(k,1) }, r_fcn, 'names' );
  if ~isempty(rout)
    syntax{end+1} = mtext{par_idx(k,1)}(1:(end-numel(rout.remainder)));
  end
  
end

syntax_out( syntax, target );
seealso = {};
example = {};

has_description = 0;

%find lists
lists = regexp( mtext, r_list, 'names' );
%definition lists
deflists = regexp( mtext, r_def, 'names' );
%tables & table dividers
table_lines = regexp( mtext, r_table_line );
tables = regexp( mtext, r_table, 'names' );
table_dividers = ~cellfun('isempty', regexp( mtext, r_table_divider ));
isparline= cellfun('isempty',lists) & cellfun('isempty', deflists) & ...
    cellfun('isempty', tables);

for k=1:size(par_idx,1)
  
  rout = regexp(mtext{par_idx(k,1)}, r_seealso, 'names');
  if ~isempty(rout)
    %see also paragraph
    seealso = strread(strtrim(rout.remainder), '%s', 'delimiter', ' ,' );
    for j=(par_idx(k,1)+1):par_idx(k,2)
      seealso = vertcat(seealso, strread(strtrim(mtext{j}),'%s', 'delimiter', ' ,' ) );
    end
    continue
  end
  
  rout = regexp(mtext{par_idx(k,1)}, r_example);
  if ~isempty(rout)
    %example paragraph
    n_ex = numel(example);
    example{n_ex+1} = strtrim(mtext((par_idx(k,1)+1):par_idx(k,2)));
    continue;
  end
  
  if ~has_description
    description_out(target)
    has_description = 1;
  end

  %normal paragraph, let's go through line by line so that we can find
  %possible lists or definition lists
  startpar(target);
  
  lineno = par_idx(k,1);
 
  while lineno<=par_idx(k,2)
   
    if  ~isempty(lists{lineno})
      %parse list
      list_collection={strtrim(lists{lineno}.item)};
      current_item = 1;
      list_indent = indent(lineno);
      lineno=lineno+1;
      while lineno<=par_idx(k,2)
        if ~isempty(lists{lineno})
          %new list item
          current_item=current_item+1;
          list_collection{current_item}=strtrim(lists{lineno}.item);
        elseif isparline(lineno) && indent(lineno)>=list_indent
          list_collection{current_item} = [list_collection{current_item} ' ' ...
                              strtrim(mtext{lineno})];      
        else
          break;
        end
        lineno=lineno+1;
      end
      list_out(list_collection,target);
    elseif ~isempty(deflists{lineno})
      %parse def list
      par_start=lineno>par_idx(k,1);
      def_collection = {};
      current_item=1;
      list_indent = indent(lineno);
      def_collection{current_item,1} = strtrim(deflists{lineno}.name);
      def_collection{current_item,2} = strtrim(deflists{lineno}.item);
      lineno=lineno+1;
      while lineno<=par_idx(k,2)
        if ~isempty(deflists{lineno})
          %new definition item
          current_item=current_item+1;
          def_collection{current_item,1} = strtrim(deflists{lineno}.name);
          def_collection{current_item,2} = strtrim(deflists{lineno}.item);
        elseif isparline(lineno) && indent(lineno)>=list_indent
          def_collection{current_item,2} = [def_collection{current_item,2} ' ' ...
                              strtrim(mtext{lineno})];
        else
          break
        end
        lineno=lineno+1;
      end
      deflist_out(def_collection,target);
    elseif ~isempty(table_lines{lineno})
      %parse table
      table_header={};
      table_data={};
      %does table have header?
      if lineno<par_idx(k,2) && table_dividers(lineno+1)
        table_header = {tables{lineno}.cell};
        lineno=lineno+2;
      else
        table_data = {tables{lineno}.cell};
        lineno=lineno+1;
      end
      while lineno<=par_idx(k,2)
        if ~isempty(table_lines{lineno})
          table_data(end+1,1:numel(tables{lineno})) = {tables{lineno}.cell};
        elseif table_dividers(lineno)
          %ignore
        else
          break
        end
        lineno=lineno+1;
      end
      table_out(table_header,table_data,target);
    else
      %output line
      par_out(strtrim(mtext{lineno}), target);
      lineno = lineno + 1;
    end
    
  end
   
 
  endpar(target);
end


example_out( example, target );

seealso_out( seealso, target );

body = [body sprintf('\n\n')];  




  function start_out( fcn, target)
  
  switch target
   case 'html'
    body = [body '<h2>' fcn '</h2>' CR];
   case 'context'
    body = [body '\subsection{' charreplace_context(fcn) '}' CR];
   case 'rst'
    fcn = charreplace_rst(fcn);
    body = [body sprintf('%s\n%s\n\n', fcn, repmat('^', 1, numel(fcn)))];
  end
  
  end

  function synopsis_out( synopsis, target )

  switch target
   case 'html'
    body = [body '<h3>synopsis</h3>' CR synopsis CR];
   case 'context'
    body = [body '\helpitem{synopsis}' charreplace_context(synopsis) CR CR];
   case 'rst'
    synopsis = charreplace_rst(synopsis);
    body = [body sprintf('%s\n%s\n\n%s\n\n', 'synopsis', repmat('~', 1, numel('synopsis')), synopsis)];
  end
  
  end

  function syntax_out(syntax, target )
  
  if isempty(syntax)
    return
  end
  
  switch target
   case 'html'
    body = [body '<h3>syntax</h3><pre>' CR];
    for k=1:numel(syntax)
      body = [body '    ' syntax{k} CR];
    end
    body = [body '</pre>' CR];
   case 'context'
    syntax = strrep(syntax, fcn, lower(fcn));
    body = [body '\helpitem{syntax}' CR];
    for k=1:numel(syntax)
      body=[body '\type<<' syntax{k} '>>'];
      if k<numel(syntax)
        body=[body '\crlf' CR];
      else
        body=[body CR CR];
      end
    end
    
   case 'rst'
     body = [body sprintf('%s\n%s\n\n', 'syntax', repmat('~', 1, numel('syntax')))];
     body = [body '::' CR CR];
     for k=1:numel(syntax)
       body = [body '    ' syntax{k} CR];
     end
     body = [body CR];
     
  end
  
  end

  function seealso_out(seealso, target)
  
  if isempty(seealso)
    return
  end
  
  switch target
   case 'html'
    seealso = lower(seealso);
    body = [body '<h3>see also</h3>' CR];
    body = [body seealso{1} ' '];
    if numel(seealso)>1
      for kk=2:numel(seealso)
        body = [body '&mdash ' seealso{kk} ' '];
      end
    end
   case 'context'
    seealso = lower(seealso);
    body = [body '\helpitem{see also}' CR ];
    body = [body charreplace_context(seealso{1}) ' '];
    if numel(seealso)>1
      for k=2:numel(seealso)
        body = [body '--- ' charreplace_context(seealso{k}) ' '];
      end
    end
   case 'rst'
    seealso = lower(seealso);
    body = [body sprintf('%s\n%s\n\n', 'see also', repmat('~', 1, numel('see also')))];
    body = [body charreplace_rst(seealso{1}) ' '];
    if numel(seealso)>1
      for kk=2:numel(seealso)
        body = [body '- ' charreplace_rst(seealso{kk}) ' '];
      end
    end
    body = [body CR];
  end

  end

  function example_out(example, target)
  
  if isempty(example)
    return
  end
  
  for k=1:numel(example)
    if isempty(example{k})
      continue
    end
    switch target
     case 'html'
      body = [body '<h3>example</h3><pre>' CR];      
      for j=1:numel(example{k})
        body = [body example{k}{j} CR];
      end
      body = [body '</pre>' CR];      
     case 'context'
      body = [body '\helpitem{example}' CR];
      for j=1:numel(example{k})
        body=[body '\type<<' example{k}{j} '>>'];
        if j<numel(example{k})
          body=[body '\crlf' CR];
        else
          body=[body CR CR];
        end
      end
     case 'rst'
      body = [body sprintf('%s\n%s\n\n', 'example', repmat('~', 1, numel('example')))];
      body = [body '.. code-block:: matlab' CR CR]; 
      for j=1:numel(example{k})
        body = [body '    ' example{k}{j} CR];
      end
      body = [body CR];
    end
  end
  
  end


  function description_out(target)
  
  switch target
   case 'html'
    body = [body '<h3>description</h3>' CR];      
   case 'context'
    body = [body '\helpitem{description}'];
   case 'rst'
    body = [body sprintf('%s\n%s\n\n', 'description', repmat('~', 1, numel('description')))];      
  end
  
  end
    
  function par_out(par, target)
  
  switch target
   case 'html'
    body = [body par CR];
   case 'rst'
    body = [body charreplace_rst(par) CR];
   case 'context'
    body = [body charreplace_context(par) CR];
  end
    
  end

  function startpar(target)
  switch target
   case 'html'
    body = [body '<p>' CR];
   case {'context', 'rst'}
    %body = [body sprintf('\n')];
  end
  end
  
  function endpar(target)
  switch target
   case 'html'
    body = [body '</p>' CR];
   case {'context', 'rst'}
    body = [body CR];
  end
  end

  function list_out(list_collection, target)
  
  if isempty(list_collection)
    return
  end
  
  switch target
   case 'html'
    body = [body '<ol>' CR];
    for kk=1:numel(list_collection)
      body = [body '<li>' list_collection{kk}  '</li>' CR];
    end
    body = [body '</ol>' CR];
   case 'context'
    list_collection = strrep(list_collection, '_', '\_');
    body = [body '\startitemize[n][stopper=. , inbetween=\nowhitespace, before=\nowhitespace]' CR];
    for kk=1:numel(list_collection)
      body = [body '\item ' charreplace_context(list_collection{kk}) CR];
    end
    body = [body '\stopitemize' CR];
   case 'rst'
    body = [body CR];       
    for kk=1:numel(list_collection)
        body = [body '- ' charreplace_rst(list_collection{kk}) CR];
    end
    body = [body CR];       
  end
  
  end

  function deflist_out(def_collection, target)
  
  if isempty(def_collection)
    return
  end  
  
  switch target
   case 'html'
    body = [body '<dl>' CR];
    for kk=1:size(def_collection,1)
      body = [body '<dt>' def_collection{kk,1} '</dt><dd>' def_collection{kk,2} '</dd>' CR]; %#ok
    end
    body = [body '</dl>' CR];    
   case 'context'
    if par_start
      body = [body CR];
    end
   
    for kk=1:size(def_collection,1)
      body = [body '\parameter{' charreplace_context(def_collection{kk,1}) '} ' ...
              charreplace_context(def_collection{kk,2}) ' \par' CR];
    end
   case 'rst'
    body = [body CR];       
    for kk=1:size(def_collection,1)
        body=[body '*' charreplace_rst(def_collection{kk,1}) '*' CR '    ' charreplace_rst(def_collection{kk,2}) CR CR];
    end

  end
  
  end

  function table_out(table_header, table_data, target)
    
  if isempty(table_data)
    return
  end
  
  switch target
   case 'html'
    body = [body CR '<table>' CR];
    if ~isempty(table_header)
      body = [body '<tr>' CR];
      for kk=1:numel(table_header)
        body = [body '<th>' table_header{kk} '</th>' CR];
      end
      body = [body '</tr>' CR];
    end
    for jj=1:size(table_data,1)
      body = [body '<tr>' CR];
      for kk=1:size(table_data,2)
        body = [body '<td>' table_data{jj,kk} '</td>' CR];
      end
      body = [body '</tr>' CR];
    end
    body = [body '</table>' CR];
   case 'context'
    body = [body CR '\setupTABLE[r][each][frame=off]' CR];
    body = [body '\setupTABLE[c][each][align=middle]' CR];
    if ~isempty(table_header)
      body = [body '\setupTABLE[r][first][bottomframe=on]' CR];
    end
    body = [body '\bTABLE[option=stretch]' CR];
    if ~isempty(table_header)
      body = [body '\bTABLEhead' CR '\bTR' CR];
      for kk=1:numel(table_header)
        body = [body '\bTH ' charreplace_context(table_header{kk}) ' \eTH' ...
                CR];
      end
      body = [body '\eTR' CR '\eTABLEhead' CR];
    end
    body = [body '\bTABLEbody' CR];
    for jj=1:size(table_data,1)
      body = [body '\bTR' CR];
      for kk=1:size(table_data,2)
        body = [body '\bTC ' charreplace_context(table_data{jj,kk}) ' \eTC' ...
                CR];
      end
      body = [body '\eTR' CR];
    end
    body = [body '\eTABLEbody' CR];
    body = [body '\eTABLE' CR];
    
   case 'rst'
   
     body = [body CR 'table ignored' CR];  
       
  end
    
  end
  
end