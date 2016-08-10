function [headerstruct] = header2mat(adfile)
%HEADER2MAT - Read the header of a file
%
%  header = HEADER2MAT(filename)
%
%  FILENAME is the name of the cluster boundary file.
%
%  -----------------------------------------------------------------------   
%  OUTPUT:
%
%  a structure containing the fields in the header
%
%  -----------------------------------------------------------------------
%  EXAMPLE:
%
%  header = header2mat('abcd12.tt')
%  
%  Retrieves header information from the abcd12.tt file
%
%  Copyright (c) 2003 David P. Nguyen and Fabian Kloosterman
%  December 9, 2003

%    This file is part of the MWL2MALAB toolbox.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Id: header2mat.m,v 1.4 2004/11/02 05:09:42 fabian Exp $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%% CHECK ARGUMENTS %%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(class(adfile), 'char') == 1
  % FILE NAME WAS PASSED
  adfd = fopen(adfile, 'r');
else
  % FILE DESCRIPTOR WAS PASSED
  adfd = adfile
  [Filename, Permission, MachineFormat] = fopen(adfd);
  if isempty(Filename)
    return;
  else
    PlaceHolder = ftell(adfd);
  end
  
end

headerstruct = [];



%%%% PREPARE TO READ IN HEADER
EndHeaderString = '%%ENDHEADER';
tmp_string = [];
nFields = 0;

%%%% Move to the end of the header while getting field names
while(strncmp(EndHeaderString, tmp_string, length(EndHeaderString))~=1)      
  tmp_string = fgets(adfd);
  [T, R] = strtok(tmp_string, ':');
  
  if length(T) > 0

    good = find((T ~= ':')&(T ~= '[')&(T ~= ']')&(T~='%')&(T~=' '));
    T = T(good);

    if (isvarname(T) == 1) & (length(R) > 0)    

      % strip off the whitespace in the beginning
      R = R(2:end);
      while(isspace(R(1)))
        R = R(2:end);
      end

      % read in the values for the fields
      % if it is a number, detect the number 
      % if it is not a number, leave it in string format
      [A, count, errmsg, nextindex] = sscanf(R, '%f');
      if ((count > 0) | (nextindex > length(R)))
        headerstruct = setfield(headerstruct, T, A);
      else
        headerstruct = setfield(headerstruct, T, R);
      end
    end
  end
end

% close file or place file position
if strcmp(class(adfile), 'char') == 1
  fclose(adfd);
else
  fseek(adfd, PlaceHolder, 'bof');
end
