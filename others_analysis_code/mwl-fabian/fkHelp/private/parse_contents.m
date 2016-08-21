function sections = parse_contents( filename )
%PARSE_CONTENTS

sections = struct('name', {}, 'files', {}, 'descriptions', {});

if ~exist( filename, 'file')
  return
end

contents = textread(filename,'%s','delimiter','\n','whitespace','');

pat = '(?<function>[^-]+)-(?<description>[^-]*)';

for k = 3:numel(contents)   %skip first two header lines
  parse_line = contents{k};
  parse_line( parse_line=='%' ) = [];
  parse_line = strtrim(parse_line);
    
  if ~isempty(parse_line)
    re = regexp(parse_line, pat, 'names');
        
    if isempty(re)
      sections(end+1) = struct('name', parse_line, 'files', {{}}, ...
                               'descriptions', {{}} );
    else
      sections(end).files{end+1} = strtrim(re(1).function);
      sections(end).descriptions{end+1} = strtrim(re(1).description);
    end
    
  end    
  
end

