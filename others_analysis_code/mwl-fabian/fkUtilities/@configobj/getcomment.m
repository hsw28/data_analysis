function [comment, inline] = getcomment( C, key )
%GETCOMMENT get comment associate with configobj or a key
%
%  [comment,inline]=GETCOMMENT(c) retrieves comment and inline comment of
%  a configobj section.
%
%  [comment,inline]=GETCOMMENT(c,key) retrieves comment and inline comment of
%  a key.
%

%  Copyright 2005-2008 Fabian Kloosterman


if nargin==1
  %return section comments
  comment = C.section_comments;
  inline = C.section_inline_comments;
elseif nargin==2 && ischar(key) && ismember( key, fieldnames( C.keys ) )
  %return key comments
  comment = C.comments.(key);
  inline = C.inline_comments.(key);
elseif nargin==2
  error('ConfigObj:setcomment:invalidKey', 'Invalid key')
else
  error('ConfigObj:setcomment:invalidArguments', ['Invalid input ' ...
                      'arguments'])
end
  
  
