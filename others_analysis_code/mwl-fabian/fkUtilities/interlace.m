function y=interlace(a,b,ind,dim)
%INTERLACE Insert Subarrays into Array
%
%  y=INTERLACE(a,b,ind,dim) inserts the array b into array a after all indices
%  given in the vector ind along dimension dim. If dim is not given, dim is
%  set equal to the first nonsingleton dimension of a. b and a must have the
%  same class. Numeric, logical, and character classes are supported. b must
%  have the same dimensions as a along all dimensions except dim or b must
%  be a scalar that is expanded to the correct size. When ind(k)=0, the
%  array b is placed before the first index in a.
%
%  y=INTERLACE(a,c,ind,dim) where c is a cell array containing length(ind)
%  cells, inserts the contents of the k-th cell c{k} after the k-th index
%  ind(k).
%
%  Example
%    interlace(ones(3,4),1:4,2) %produces [1 1 1 1
%                                          1 1 1 1
%                                          1 2 3 4
%                                          1 1 1 1]
%
%    interlace(ones(3,4),[5 6 7],[1 2 3],2) %produces an error since B must be
%    a column since dim=2 is the column dimension
%
%    interlace(ones(3,4),[5;6;7],[1 2 3],2) %produces [1 5 1 5 1 5 1
%                                                      1 6 1 6 1 6 1
%                                                      1 7 1 7 1 7 1]
%    interlace(ones(3,4),8,[0 3],1) %produces [8 8 8 8
%                                              1 1 1 1
%                                              1 1 1 1
%                                              1 1 1 1
%                                              8 8 8 8]
%
%    interlace(ones(3,4),zeros(2,4),1) %produces [1 1 1 1
%                                                 0 0 0 0
%                                                 0 0 0 0
%                                                 1 1 1 1
%                                                 1 1 1 1]
%
%    interlace(ones(3,4),{1:4, 4:-1:1},[1 3],1) %produces [1 1 1 1
%                                                          1 2 3 4
%                                                          1 1 1 1
%                                                          1 1 1 1
%                                                          4 3 2 1]
%
%    interlace(ones(3,4),{[5;6;7],6,7},[1 1 3],2) %produces [1 5 6 1 1 7 1
%                                                            1 6 6 1 1 7 1
%                                                            1 7 6 1 1 7 1]
%
%  See also REPMAT, CAT

% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2006-02-19

if nargin<3
   error('interlace:NotEnoughInputArguments','Three or Four Inputs Required.')
end
asiz=size(a);                 % gather data about input A
aclass=class(a);
adims=ndims(a);
if nargin==3
   dim=find(asiz>1,1);
end
if isequal(aclass,'cell') || isequal(aclass,'struct')
   error('interlace:ClassNotSupported','Cell and Struct Inputs Not Supported.')
end
if isempty(dim) || numel(dim)~=1 || fix(dim)~=dim || dim<1 || dim>adims
   error('interlace:DimOutofRange','DIM Invalid.')
end
ind=ind(:);                   % make IND a vector
lind=length(ind);
N=asiz(dim);                  % length of A along chosen dimension
n=(1:N)';                     % index along chosen DIM
asiz(dim)=1;
if isempty(ind) || any(ind>N|ind<0)
   error('interlace:IndexOutofBounds','IND Value Out of Bounds.')
end
if iscell(b)                  % stretch input cell C to a column
   c=b(:);
else                          % convert input B to cell for convenience
   c=repmat({b},lind,1);
end
if length(c)~=lind
   error('interlace:ArgumentMisMatch','Size of IND Must Match Size of C.')
end
notdim=true(1,adims);
notdim(dim)=false;            % true for dimensions other than DIM
perm=[dim:adims 1:dim-1];     % permutation vector
a=permute(a,perm);            % make DIM first dimension
a=reshape(a,N,[]);            % make A 2D
ac=cell(N,1);
for k=1:N                     % places rows of A into cells
   ac{k}=a(k,:);
end
for k=1:lind                  % determine size and class of inputs
   if ~isequal(class(c{k}),aclass)
      error('interlace:ClassConflict','B or C Must Have Same Class as A')
   end
   sc=[size(c{k}) ones(1,adims-ndims(c{k}))];
   if all(sc==1)                          % scalar expansion
      c{k}=repmat(c{k},asiz);
   elseif any(sc(notdim)~=asiz(notdim))   % check conformity
      error('interlace:ArgumentMisMatch',...
         'Contents of B or C Incorrect Size for A.')
   end
   tmp=permute(c{k},perm);
   c{k}=reshape(tmp,size(tmp,1),[]); % reshape to 2D like ac
end
yc=[ac;c];                    % stack cells
[idx,idx]=sort([n;ind]); %#ok % sort indices of A and IND
yc=yc(idx);                   % apply sort to A and C
y=cat(1,yc{:});               % convert back to array from cell
asiz(dim)=size(y,1);          % new size along DIM
y=reshape(y,asiz(perm));      % put result back in original form
y=ipermute(y,perm);           % inverse permute dimensions
