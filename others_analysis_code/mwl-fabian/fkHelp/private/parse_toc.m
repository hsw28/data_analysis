function T = parse_toc( tocfile, option )
%PARSE_TOC

%if option is false, the target field is considered a callback, otherwise
%the target field is considered a reference to a html file
if nargin<2 || isempty(option)
  option=true;
end


T = struct('label', {}, 'target', {}, 'icon', {}, 'level', {});

if ~exist( tocfile, 'file' )
  return
end

%read toc file
toc_txt = textread( tocfile, '%s','delimiter','\n','whitespace','');

%replace tabs with spaces
toc_txt = deblank( strrep( toc_txt, char(9), ' ' ) );

%remove empty lines
toc_txt( strcmp( toc_txt, '' ) ) = [];

%determine levels
level = cellfun( 'length', toc_txt ) - cellfun( 'length', strtrim(toc_txt));
toc_txt = strtrim(toc_txt);

%convert to struct
for k = 1:numel(toc_txt)

  parts = strread( toc_txt{k}, '%s', 'delimiter', ':');
  
  if numel(parts)<2 || isempty(parts{1}) || isempty(parts{2})
    continue
  end
  
  if option
    target = strread( parts{2}, '%s', 'delimiter','#');
    if numel(target)==2
      parts{2} = [target{1} '.html#' target{2}];
    else
      parts{2} = [parts{2} '.html'];
    end  
  end
    
  
  if numel(parts)<3
    icon = 'book_mat.gif';
  else
    icon = [parts{3} '.gif'];
  end
  
  T(end+1) = struct('label', parts{1}, ...
                    'target', parts{2}, ...
                    'icon', icon, ...
                    'level', level(k) );
  
end