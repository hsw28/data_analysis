function delvarmat
%DELVARMAT Delete variable(s) from MAT-file
%
%  status=DELVARMAT(matfile,var1,var2,...) deletes the variables var1,
%  var2, ..., from the MAT file. The function returns 1 (failure) if the
%  MAT file doesn't exist or 0 (success) otherwise. If a variable doesn't
%  exist in the MAT file, then a warning will be displayed, but execution
%  continues.
%
%  See also SAVE, LOAD.
%
  
% Copyright (c) 1984-98 by The MathWorks, Inc.
% MEX-file function.

% Modified by Fabian Kloosterman
