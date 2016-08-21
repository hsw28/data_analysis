function props = load_props( rootdir, target, varargin )
%LOAD_PROPS load property data
%
%  props=LOAD_PROPS(rootdir,target) returns a structure with all
%  variables contained in the property data file rootdir/target.props
%
%  props=LOAD_PROPS(rootdir,target,'var1','var2',...) loads only the
%  selected variables from property data file.
%
%  props=LOAD_PROPS(rootdir,target,{'var1','var2',...}) loads only the
%  selected variables from property data file.
%
%  propnames=LOAD_PROPS(rootdir,target,0) returns a list of the names of
%  all variables in the property data file.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

props = [];

filename = fullfile( rootdir, [target '.props']);

if ~exist(filename, 'file')
    return
end

if nargin<3
  %load all contents of mat file and return structure
  props = load(filename, '-mat');
  return
elseif nargin==3 && iscell(varargin{1})
  %load selected variables only
  props = load(filename, '-mat', varargin{1}{:} );
elseif nargin==3 && isnumeric(varargin{1})
  %returns variable names in file
  props = who('-file', filename );
else
  %load selected variables only
    props = load(filename, '-mat', varargin{:} );
end