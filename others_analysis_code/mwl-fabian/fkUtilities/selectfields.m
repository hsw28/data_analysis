function S = selectfields(S, fields)
%SELECTFIELDS select fields from structure
%
%  s=SELECTFIELDS(s,fields) select the fields from the structure s.
%
%  Example
%    s = struct('a', 1, 'b', 2, 'c', 3);
%    s = selectfields(s, {'b', 'c'} );
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
    help(mfilename)
    return
end

if nargin<2
    return
end

if ~isstruct(S)
    error('selectfields:noStruct', 'Not a structure')
end

if ~ischar(fields) && ~iscellstr(fields)
    error('selectfields:invalidFields', 'Invalid fields')
end


%remove unwanted fields
fn = fieldnames(S);
fields_to_remove = setdiff( fn, cellstr( fields ) );
S = rmfield(S, fields_to_remove);
