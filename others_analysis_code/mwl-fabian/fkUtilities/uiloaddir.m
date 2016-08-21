function varargout=uiloaddir(startpath,varargin)
%UILOADDIR user interface for loaddir function
%
%  [...]=UILOADDIR(startpath,...) graphical user interface for loaddir
%  function. It will show a directory selection window and call loaddir
%  on the selected directory. The top level directory can be specified by
%  the startpath argument; if omitted it defaults to the current
%  directory.
%
%  See also: loaddir
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1 || isempty(startpath)
  startpath = '.';
end

rootdir = uigetdir(startpath,'Select a directory to load');

if rootdir(1)==0
  varargout = cell(1,nargout);
  return
else
  [varargout{1:nargout}]=loaddir(rootdir, varargin{:});
end
