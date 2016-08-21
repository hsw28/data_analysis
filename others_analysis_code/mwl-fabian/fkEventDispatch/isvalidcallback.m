function bValid = isvalidcallback( cb )
%ISVALIDCALLBACK test if callback is valid
%
%  valid=ISVALIDCALLBACK(callback) return true if callback is valid and
%  false otherwise. Valid callbacks are: 1. a string, 2. a function
%  handle, 3. a cell array with the first cell the name of a function or
%  a function handle and the remaining cells extra arguments.
%

%  Copyright (C) 2006 Fabian Kloosterman
%
%  This program is free software; you can redistribute it and/or modify it
%  under the terms of the GNU General Public License as published by the
%  Free Software Foundation; either version 2 of the License, or (at your
%  option) any later version.
%
%  This program is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
%  Public License for more details.
%
%  You should have received a copy of the GNU General Public License along
%  with this program; if not, write to the Free Software Foundation, Inc.,
%  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 

bValid = false;

if isa(cb, 'function_handle' )
  bValid = true;
elseif ischar( cb )
  bValid = true;
elseif iscell(cb) && numel(cb)>=1 && (ischar(cb{1}) || isa(cb{1},'function_handle'))
  bValid = true;
end