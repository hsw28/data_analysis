function val = dump( C, name, level )
%DUMP dump configobj to a string
%
%  s=DUMP(c) dumps the contents of a configobj to a string. This function
%  calls itself recursively for all nested sections.
%
%  s=DUMP(c,name) internal use only, specify the name of the current
%  section that is written to the string.
%
%  s=DUMP(c,name,level) internal use only, specify level of current
%  section that is written to the string.
%


%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<2 || isempty(name)
  name = '';
end

if nargin<3 || isempty(level)
  level = 0;
end

%default section name
if isempty(name) && level>0
  name = [ 'section' num2str(level) ];
end

%set indentation level
indent = repmat( ' ', 1, level-1 );

val = '';


if ~isempty(name) && level>0
  
  val = [val sprintf('\n')];
  
  %dump section comments
  ncomments = numel( C.section_comments );
  for k=1:ncomments
    if ~isempty(C.section_comments{k})
      val = [val sprintf('%s#%s\n', indent, C.section_comments{k} )];
    end
  end
  
  %dump section header
  val = [val sprintf('%s%s%s%s', indent, repmat('[', 1, level), name, ...
                     repmat(']', 1, level ) ) ];
  
  %dump section inline comment
  if ~isempty( C.section_inline_comments )
    val = [val sprintf('\t#%s\n', C.section_inline_comments)];
  else
    val = [val sprintf('\n')];
  end
  
end

%dump all keys
keys = fieldnames( C.keys );
nkeys = numel(keys);

for k = 1:nkeys
  
  %convert value to string
  keyval = validate(C.keys.(keys{k}));
  ncomments = numel( C.comments.(keys{k}) );
  
  %dump key comments
  for j=1:ncomments
    if ~isempty(C.comments.(keys{k}){j})
      val = [val sprintf('%s#%s\n', indent, C.comments.(keys{k}){j} )];
    end
  end
  
  %dump key/value
  val = [ val sprintf('%s%s = %s', indent, keys{k}, keyval ) ];
  
  %dump key inline comment
  if ~isempty( C.inline_comments.(keys{k}) )
    val = [val sprintf('\t#%s\n', C.inline_comments.(keys{k}))];
  else
    val = [val sprintf('\n')];
  end
  
end

%dump all sub sections
sections = fieldnames( C.subsections );
nsections = numel(sections);

for k=1:nsections
  %recurse
  val = [ val dump( C.subsections.(sections{k}), sections{k}, level+1 ) ];
  
end


function val = validate( val )
%VALIDATE convert value to string

if isnumeric(val) && ndims(val)<=2
  if isa(val, 'double')
    val = mat2str(val);
  else
    val = mat2str(val, 'class');
  end
elseif ischar(val) && (isvector(val) || isempty(val))
  %if isempty(val)
  val = sprintf('''%s''',val);
  %end
elseif iscell(val) && ndims(val)<=2
  val = cell2str(val);
elseif islogical(val) && ndims(val)<=2
  val = mat2str( val );
else
  error('ConfigObj:dump:invalidValue', 'Invalid value')
end

%replace \n and \r special characters
val = strrep( val, char(10), '\n' );
val = strrep( val, char(13), '\r' );
