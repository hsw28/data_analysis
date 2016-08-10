function p2mat()
%P2MAT - Import diode position data
%
%  pdata = P2MAT(filename, [option string], [index])
%
%  FILENAME is the name of the diode position file.
%
%  OPTION STRING is like the option string in the plot command.
%  The following options are available:
%    
%     Filter Type = (n)one, spike (i)ndex, (r)ecord index,
%                   (t)imstamps, (s)econds
%     Indexing Type = (a)rray, (b)lock
%
%     Relative Indexing = (|) relative to start of file,
%                         (>) relative to first index of vector
%                         
%     Verbose Level = (0) only errors, (1) errors and warnings, 
%                     (2) err, warn, some info, (3) very detailed
%
%     Data Returned = (+) return all data
%                     (-) return timestamps and id
%
%  INDEX can either be a block style or vector style.  In
%  block style, you specify an Nx2 matrix where N is the number of
%  blocks you wish to recieve.  In array style, you specify a Nx1
%  array where N is the number of indices you would like to
%  retreive. 
%
%  The following options are not supported by the p2mat function:
%  spike index filtering.
%
%  Default values are 'n1+', however, if you specify a filter other
%  than none, the default indexing type is block style.
%
%  -----------------------------------------------------------------------   
%  OUTPUT:
%  
%  pdata.frame is the id of the frame
%  pdata.timestamp is the timestamp in seconds
%  pdata.x is the x coordinate
%  pdata.y is the y coordinate
%  pdata.frame0 is a string label describing frame 0
%  pdata.frame1 is a string label describing frame 1
%  pdata.info is the structure containing file information
%
%  -----------------------------------------------------------------------
%  EXAMPLE:
%
%  pdata = p2mat('pos12.p', 's|>', [200 100])
%
%  This example retrieves 100 seconds of diode position data
%  starting 200 seconds after the first timestamp in the file.
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
%    The function p2mat is implemented as a mex-function.
%    This m-file only serves for purposes of help and documentation.
