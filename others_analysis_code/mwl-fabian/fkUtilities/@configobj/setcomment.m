function C = setcomment( C, varargin)
%SETCOMMENT set comments or inline comment of configobj or a key
%
%  c=SETCOMMENT(c,section_comment) sets the comment of a section. A
%  comment can be a string or a cell array of strings.
%
%  c=SETCOMMENT(c,section_comment,'inline') sets the inline comment of a
%  section. An inline comment can only be a string.
%
%  c=SETCOMMENT(c,key,key_comment) sets the comment of a key. A comment
%  can be a string or a cell array of strings.
%
%  c=SETCOMMENT(c,key,key_comment,'inline') sets the inline comment of a
%  key. An inline comment can only be a string.
%
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<2
  return
end

%is this an inline comment?
inline = ( ischar( varargin{end} ) && ismember( varargin{end}, {'inline'} ) );


if nargin==2 || (nargin==3 && inline )
  %section comment
  if ~inline && ischar( varargin{1} )
    comment = cellstr( varargin{1} );
  elseif ~inline && ~iscellstr( varargin{1} )
    error('ConfigObj:setcomment:invalidComment', 'Invalid comment')
  elseif inline && ~ischar( varargin{1} )
    error('ConfigObj:setcomment:invalidComment', 'Invalid inline comment')
  else
    comment = varargin{1};
  end
  if inline
    C.section_inline_comments = comment;
  else
    C.section_comments = comment;
  end
elseif nargin==3 || (nargin==4 && inline )
  %key comment
  if ~ischar( varargin{1} ) || ~ismember( varargin{1}, fieldnames( C.keys ) )
    error('ConfigObj:setcomment:invalidKey', 'Invalid key')
  else
    key = varargin{1};
  end
  if ~inline && ischar( varargin{2} )
    comment = cellstr( varargin{2} );
  elseif ~inline && ~iscellstr( varargin{2} )
    error('ConfigObj:setcomment:invalidComment', 'Invalid comment')
  elseif inline && ~ischar( varargin{2} )
    error('ConfigObj:setcomment:invalidComment', 'Invalid inline comment')
  else
    comment = varargin{2};
  end
  if inline
    C.inline_comments.(key) = comment;
  else
    C.comments.(key) = comment;
  end
else
  error('ConfigObj:setcomment:invalidArguments', 'Invalid input arguments')
end
