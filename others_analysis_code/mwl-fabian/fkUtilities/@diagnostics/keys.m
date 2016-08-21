function [k, comments, inline] = keys( L )
%KEYS get key name, their comments and inline comment
%
%  [keys,comments,inline]=KEYS(d) retrieve all key names and their
%  comments from a diagnostics object.
%

%  Copyright 2005-2008 Fabian Kloosterman


[k, comments, inline] = keys( L.configobj );
