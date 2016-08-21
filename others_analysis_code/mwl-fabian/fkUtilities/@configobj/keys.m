function [k, comments, inline] = keys( C )
%KEYS get key name, their comments and inline comment
%
%  [keys,comments,inline]=KEYS(c) retrieve all key names and their
%  comments from a configobj.
%

%  Copyright 2005-2008 Fabian Kloosterman

k = fieldnames( C.keys );
comments = struct2cell( C.comments );
inline = struct2cell( C.inline_comments );
