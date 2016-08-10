function event2mat()
%EVENT2MAT - Import event strings
%
%  eventdata = EVENT2MAT(filename)
%
%  FILENAME is the name of the event file.
%
%  -----------------------------------------------------------------------   
%  OUTPUT:
%  
%  eventdata.timestamp is the time vector in seconds.
%  eventdata.event is a cell array containing event strings
%  eventdata.info is a structure containing event file parameters
%
%  -----------------------------------------------------------------------
%  EXAMPLE:
%
%  eventdata = event2mat('cool.es')
%
%  Retrieves all the events in this file.
%
%  Copyright (c) 2003 David P. Nguyen and Fabian Kloosterman
%  December 9, 2003

%    This file is part of the MWL2MATLAB toolbox.
%
%    MWL2MATLAB is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    MWL2MATLAB is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with MWL2MATLAB; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
%    The function event2mat is implemented as a mex-function.
%    This m-file only serves for purposes of help and documentation.
