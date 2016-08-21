function txt = charreplace_rst( txt )
%CHARREPLACE_CONTEXT

%replace some characters
txt = regexprep(txt, '(?<!\\)([_|])', '\\$1');
