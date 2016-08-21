function txt = charreplace_context( txt )
%CHARREPLACE_CONTEXT

%replace some characters
txt = regexprep(txt, '(?<!\\)([%${}_&#])', '\\$1');
txt = regexprep(txt, '([\[\]<>|^])', '\\type{$1}' );
