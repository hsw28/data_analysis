function setconfigpath(rootdir)
%SETCONFIGPATH set configuration path in preferences
%
%  SETCONFIGPATH deletes configuration path
%
%  SETCONFIGPATH(p) sets configuration path to p
%
%  See also: configobj, loadconfig, saveconfig
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1 || isempty(rootdir)
  
  p = getpref('configuration');
  if ~isempty(p) && isfield(p, 'path')
    rmpref('configuration','path');
  end
  
elseif ischar(rootdir) 
  
  try
    rootdir = fullpath( rootdir );
  catch
    answer = input('path does not exist, create it? ','s');
    if ismember(lower(answer), {'y', 'yes'})
      [success, msg, msgid] = mkdir( rootdir ); %#ok
      if ~success
        error('setconfigpath:invalidPath', 'Cannot create path')
      end
    end
  end
  
  setpref('configuration','path',rootdir);
  
  
  
else
  
  error('setconfigpath:invalidPath', 'Invalid path' )
  
end
