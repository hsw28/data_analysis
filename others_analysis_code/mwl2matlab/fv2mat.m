function fv2mat()
%FV2MAT - Import spike parameters (feature vectors)
%
%  features = FV2MAT(filename, [features], [option string], [index])
%
%  FILENAME is the name of the feature vector file.
%
%  FEATURES is an optional vector that specifies the features as indices
%  or a cell array of strings specifying the feature field names or
%  any of the following special strings: 'all', 'amp' (incl. id,
%  t_px, t_py, t_pa, t_pb), 'pos' (incl. id, pos_x, pos_y)
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
%  INDEX can either be a block style or vector style.  In
%  block style, you specify an Nx2 matrix where N is the number of
%  blocks you wish to recieve.  In array style, you specify a Nx1
%  array where N is the number of indices you would like to
%  retreive. 
%
%  Default values are 'n1', however, if you specify a filter other
%  than none, the default indexing type is block style.
%
%  -----------------------------------------------------------------------   
%  OUTPUT:
%  
%  features.featurenames contains the features
%  features.featuredata is a NxM matrix containing N samples and M features 
%  features.info contains additional information about the file
%
%  -----------------------------------------------------------------------
%  EXAMPLE:
%
%  features = fv2mat('feat.pxyabw', {'pos_x','pos_y'}, 's', [101.5 115.5]) 
%  
%  This retrieves the position of spikes between 101.5 to 115.5 seconds.
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
%    The function fv2mat is implemented as a mex-function.
%    This m-file only serves for purposes of help and documentation.
