function clusterbounds = cb2mat(file, clusterids)
%CB2MAT - Import cluster boundaries
%
%  bounds = CB2MAT(filename, [clusters])
%
%  FILENAME is the name of the cluster boundary file.
%
%  CLUSTERS is an optional vector that specifies the clusters to
%  import.
%
%  -----------------------------------------------------------------------   
%  OUTPUT:
%  
%  an array of structures with the following fields:
%
%  bounds.clusterid contains the cluster number
%  bounds.polygons is an array of structures with the following fields
%         polygons.axis contains the projections in which boundary
%           is defined
%         polygons.axisnames contains the names of the projections
%         polygons.x1 is a vector of values along the first axis
%         polygons.x2 is a vector of values along the second axis
%
%  -----------------------------------------------------------------------
%  EXAMPLE:
%
%  bounds = cb2mat('abcd12.cb', [1 3 5])
%  
%  Retrieves the boundaries of clusters 1, 3 and 5 from abcd12.cb.
%
%  Copyright (c) 2003 David P. Nguyen and Fabian Kloosterman
%  December 9, 2003

%    This file is part of the MWL2MATLAB toolbox
%
%    MWl2MATLAB is free software; you can redistribute it and/or modify
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
%    along with Foobar; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Id: cb2mat.m,v 1.4 2004/11/02 05:09:42 fabian Exp $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

usage1 = 'usage: clusterbounds = cb2mat(cbfile, [clusterids])';

if (nargin<1)
     disp(usage1);
     return;
end

allclusters = 0;
if (nargin<2)
     allclusters = 1;
end

%does file exist and can we open it?
[fid, message] = fopen(file,'r');

if (fid<0)
   warning('cb2mat: unable to open file');
   y=-1;
   return;
end
   
%does it start with magical string?
   lin = fgetl(fid);
if (lin==-1 | strncmp(lin,'%%BEGINHEADER',13)~=1)
   warning('cb2mat: file not recognized');
   y=-1;
   return;
end



%loop until we find magical string
while (~feof(fid) & strncmp(lin,'%%ENDHEADER',11)~=1)
   lin = fgetl(fid);
   %is it a File Type field?
   if (findstr(lin, '% File type:'))
      if (~(findstr(lin, 'Ascii')))
         warning('cb2mat: file is not Ascii')
         y=-1;
         return;
      end
   end
end

if (feof(fid))
   warning('cb2mat: no data, abort');
   y=1;
   return;
end

coord = [];
count = 0;
while (~feof(fid))
   lin = fgetl(fid);
   if ~(isempty(deblank(lin)))
      cid = str2num(lin);
      pnum = str2num(fgetl(fid));
      pname1 = fgetl(fid);
      pname2 = fgetl(fid);
      numcoord = str2num(fgetl(fid));
      for i=1:numcoord 
         coord(i,1:2) = str2num(fgetl(fid));
      end
      
      if (allclusters==1 | find(clusterids == cid))
         count=count+1;
         y(count).clusterid = cid;
         y(count).projections = pnum;
         y(count).projectnames = {pname1 pname2};
         y(count).bounds.x = coord(:,1);
         y(count).bounds.y = coord(:,2);
      end
         
   end
end

i = [y.clusterid];
[ii, pi] = sort(i);

[u1, u2, u3] = unique(ii);

nclust = length(u1);

npoly(1:nclust) = 0;



for loop = 1:length(y)
  index = find(u1==y(loop).clusterid);
  npoly(index) = npoly(index)+1;
  cb(index).clusterid = u1(index);
  cb(index).polygons(npoly(index)).axis = y(loop).projections;
  cb(index).polygons(npoly(index)).axisnames = ...
      y(loop).projectnames;
  cb(index).polygons(npoly(index)).x1 = y(loop).bounds.x;
  cb(index).polygons(npoly(index)).x2 = y(loop).bounds.y;  
end


clusterbounds = cb;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Log: cb2mat.m,v $
% Revision 1.4  2004/11/02 05:09:42  fabian
% removed mwl2matlab.m file and instead created a Contents.m file, listing all functions
%
% Revision 1.3  2004/11/02 04:58:59  fabian
% checked and corrected documentation in .m files
%
% Revision 1.2  2003/12/10 00:34:48  dpnguyen
% Fabian made changes to clusterbounds, he rearranged the output structure
% such that all boundaries are grouped by cluster.
%
% Revision 1.1  2003/11/11 06:03:06  dpnguyen
% restarting the repository once again
% boy, what a bunch of amateurs
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
