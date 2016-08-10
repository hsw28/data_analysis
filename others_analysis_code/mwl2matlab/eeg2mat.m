function eeg2mat()
%EEG2MAT - Import EEG data
%
%  eegdata = EEG2MAT(filename, [channels], [options string], [index])
%
%  FILENAME is the name of the eeg file.
%
%  CHANNELS is an optional vector that specifies the channels to
%  import.
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
%  The following options are not supported by the eeg2mat function:
%  array style indexing and spike index filtering.
%
%  Default values are 'n1+', however, if you specify a filter other
%  than none, the default indexing type is block style.
%
%  -----------------------------------------------------------------------   
%  OUTPUT:
%  
%  eegdata.time is the time vector in seconds.
%  eegdata.data is a NxM matrix containing N samples and M channels 
%  eegdata.info is a structure containing eeg parameters
%
%  -----------------------------------------------------------------------
%  EXAMPLE:
%
%  eegdata = eeg2mat('abcd12.eeg', [1 2], 'bs|', [1 1.1])
%  
%  Retreives 2 channels of data from abcd12.eeg.  The data is 0.1 seconds
%  long and the data starts 1 second after the first timestamp
%  in the file.
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
%    The function eeg2mat is implemented as a mex-function.
%    This m-file only serves for purposes of help and documentation.
