function varargout=loaddir(rootdir,varargin)
%LOADDIR executes a load command for directory
%
%  [...]=LOADDIR(rootdir) runs the loadme.m file in rootdir and returns
%  the requested outputs of loadme or no outputs if loadme is a script.
%
%  [...]=LOADDIR(rootdir,...) additional input arguments are passed to
%  the loadme function.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1
  rootdir='.';
end

curdir = pwd;

cd(rootdir);
  
if ~isempty(dir('loadme.m'))
  
  clear('loadme')
  
  try
    nout = nargout('loadme'); %#ok
                              %it's a function
    try
      [varargout{1:nargout}]=loadme(varargin{:});
    catch
      disp(lasterr)
    end
    
  catch
    %it's a script, evaluate in base workspace
    try
      evalin('base', 'loadme');
    catch
      disp(lasterr)
    end
    
  end

else
  %load all .mat file
  matfiles = dir('*.mat');
  for k=1:numel(matfiles)
    try
      evalin('base', ['load ' matfiles(k).name])
    catch
    end
  end
end

cd(curdir);
