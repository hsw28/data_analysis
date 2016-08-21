function s = sections( C )
%SECTIONS get names of subsections
%
%  s=SECTIONS(c) retrieve section names.
%

%  Copyright 2005-2008 Fabian Kloosterman

s = fieldnames( C.subsections );
