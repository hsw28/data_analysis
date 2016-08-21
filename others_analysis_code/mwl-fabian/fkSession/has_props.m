function tf = has_props( rootdir, target, varargin )
%HAS_PROPS checks if properties exist
%
%  b=HAS_PROPS(rootdir,target) returns true if property data file exists
%  and false otherwise.
%
%  b=HAS_PROPS(rootdir,target,'var1','var2',...) returns true for each
%  variable that is present in the property data file contains and false
%  otherwise.
%
%  b=HAS_PROPS(rootdir,target,{'var1','var2',...}) returns true for each
%  variable that is present in the property data file contains and false
%  otherwise.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

filename = fullfile( rootdir, [target '.props']);

tf = exist(filename, 'file');

if nargin<3
    return
elseif nargin==3 && iscell(varargin{1})
    if ~tf
        tf = zeros( size(varargin{1} ) );
    else
        w = who('-file', filename);
        tf = ismember( varargin{1}, w );
    end
else
    if ~tf
        tf = zeros( size(varargin) );
    else
        w = who('-file', filename);
        tf = ismember( varargin, w );        
    end
end
    