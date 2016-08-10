function xcluster = cl2mat(cl_file)
%CL2MAT - Import clusters
%
%  cluster = CL2MAT(filename)
%
%  FILENAME is the name of the cluster file.
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
%  cluster = cl2mat('abcd12.cl')
%  
%  Retrieves the cluster data from abcd12.cl.
%
%  Copyright (c) 2003 David P. Nguyen and Fabian Kloosterman
%  December 9, 2003

%    This file is part of the MWL2MATLAB toolbox
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
%% $Id: cl2mat.m,v 1.7 2004/11/02 05:09:42 fabian Exp $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

usage1 = 'usage: cluster = cl2mat(clfile)';

if (nargin<1)
     disp(usage1);
     return;
end


%%%%%%%% EXTRACT HEADER INFORMATION 
%% Open file
xclust_file = fopen(cl_file, 'r');
if(xclust_file < 0)
   error(['Could not open file: ', cl_file]);
   return;
end

end_string = '%%ENDHEADER';
n = length(end_string);
tmp_string = ' ';

xheader = [];

%% Move to end of the header and get field names
fieldN = 0;
while (strncmp(end_string, tmp_string, n) ~= 1)
   tmp_string = fgets(xclust_file);
   [T, R] = strtok(tmp_string, ' :');
   [T, R] = strtok(R);
   
   if length(T) > 0
     if strncmp(T(end), ':', 1)
       T = T(1:end-1);
     end     
     xheader = setfield(xheader, T, R);
   end
   
end

fclose(xclust_file);


%% Open file
xclust_file = fopen(cl_file, 'r');
if(xclust_file < 0)
   error(['Could not open file: ', cl_file]);
   return;
end

end_string = '%%ENDHEADER';
n = length(end_string);
tmp_string = ' ';


%% Move to end of the header and get field names
fieldN = 0;
while (strncmp(end_string, tmp_string, n) ~= 1)
   tmp_string = fgets(xclust_file);
   [T, R] = strtok(tmp_string);
   [T, R] = strtok(R);
   
   if strncmp(T, 'Fields', 6) == 1     
     while(length(T) > 0)     
       [T, R] = strtok(R);
       if length(T) > 0
         fieldN = fieldN + 1;
         fieldnames{fieldN} = strtok(T, ',');;
       end
     end
   end
end

start_pos = ftell(xclust_file);
% StartReading in the Fields
% reads in all the floats at once
tmp = fscanf(xclust_file, '%f');

% Create the Array Structure
xcluster = [];
xcluster.featurenames = fieldnames;
xcluster.featuredata = reshape(tmp, fieldN, length(tmp)/fieldN)';
xcluster.info.source = xheader;
xcluster.info.mwltype = 'cluster';

% Find 'id' field
i = find(ismember(xcluster.featurenames, 'id'));
if ~isempty(i)
  xcluster.featuredata(:,i) = xcluster.featuredata(:,i) + 1;
end


%for i = 1:fieldN 
%  try
%    xcluster = setfield(xcluster, fieldnames{i}, []);
%  catch
%    keyboard
%  end
%end

%nSpikes = length(tmp)/fieldN;
%for j = 1:fieldN
%  eval(sprintf('[xcluster.%s] = deal(tmp(%d:%d:end));', ...
%               fieldnames{j}, j, fieldN));
%end
%
%xclustinfo.hdr = xheader;
%xclustinfo.cl = xcluster;
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Log: cl2mat.m,v $
% Revision 1.7  2004/11/02 05:09:42  fabian
% removed mwl2matlab.m file and instead created a Contents.m file, listing all functions
%
% Revision 1.6  2004/11/02 04:58:59  fabian
% checked and corrected documentation in .m files
%
% Revision 1.5  2004/05/18 18:16:12  fabian
% the function now returns spike-IDs as one-based (instead of zer0-based), such that they can be easily plugged into the tt2mat function
%
% Revision 1.4  2004/01/28 22:04:20  dpnguyen
% adding mwltinitsession.m
%
% Revision 1.3  2004/01/14 01:35:27  dpnguyen
% updated output structures to include mwltype under each info field
%
% Revision 1.2  2003/12/10 18:28:53  fabian
% changed step 4 in the instructions in Readme.txt: change to MWLTools/adio directory
% in makeadio.m commented out lines that compile posest.c and diodeconfig.c
% cl2mat will now display usage string if no input arguments are supplied
%
% Revision 1.1  2003/12/10 00:36:09  dpnguyen
% Fabian changed David's cl2mat so that it conforms with the output of fv2mat.
% He had a liitle help, but not that much, because he is the coolest!
%
% Revision 1.7  2003/08/15 01:44:11  dpnguyen
% Changes needed for EEG to work
%
% Revision 1.6  2003/06/13 13:59:41  dpnguyen
% unsure what happened in this round
%
% Revision 1.5  2003/05/13 19:45:21  dpnguyen
% centerwaveforms had major bugs overall
% added features to viewaaveforms
% tt2mat files got changes in the indexing (assumes 0 is first id)
%
% Revision 1.4  2003/05/09 14:37:09  dpnguyen
% added cvs Id and Log tags to all the files
