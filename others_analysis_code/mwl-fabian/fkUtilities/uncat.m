function varargout=uncat(dim,a)
%UNCAT Unconcatenate Array
%
%  [a1,a2,...]=UNCAT(dim,a) unconcatenates the array a along dimension
%  dim. The number of left hand side arguments should match
%  size(a,dim). All outputs are the same size as a, but have dimension 1
%  along dimension dim.
%
%  Note: CAT(dim,a1,a2,...) peforms the inverse operation.
%
%  Example
%    [A,B,C] = UNCAT(1,eye(3,4)) returns the individual rows:
%                                A = [1 0 0 0]
%                                B = [0 1 0 0]
%                                C = [0 0 1 0]
%
%  Example
%    C = CELL(4,1);
%    [C{:}] = UNCAT(2,eye(3,4)) returns the individual columns in cells:
%                               C{1} = [1 0 0 ]'
%                               C{2} = [0 1 0]'
%                               C{3} = [0 0 1]'
%                               C{4} = [0 0 0]'
%
%  Example
%    D = {'one','two',eye(3)};
%    A = UNCAT(1,D) returns  A = D  since size(D,1)=1  but
%    [A,B,C] = UNCAT(2,D) returns
%                         A = 'one'
%                         B = 'two'
%                         C = eye(3)
%
%  Example
%    [A,B] = UNCAT(3,ones(3,4,2)) returns
%                                 A = ones(3,4);
%                                 B = ones(3,4);
%
%  See also CAT, DEAL, NUM2CELL, MAT2CELL, CELL2MAT
%

% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2006-02-28

% modified by Fabian Kloosterman
% 2006-11-12

if nargin~=2
   error('uncat:IncorrectInputArguments','Two Input Arguments Required.')
end
adim=ndims(a);
if isempty(dim) || numel(dim)~=1 || fix(dim)~=dim || dim<1
   error('uncat:DimOutofRange','DIM Invalid.')
end
N=size(a,dim);
if nargout>N     % MATLAB produces an error for this so catch it here first
   error('uncat:ArgumentNumberMismatch',...
      'Only %d Output Arguments Expected',N)
elseif nargout<N
   warning('uncat:ArgumentNumberMismatch',...
      '%d Output Arguments Expected',N)
end
cidx=repmat({':'},1,max(adim,dim));
varargout=cell(1,nargout);
for k=1:nargout
   cidx{dim}=k;
   varargout{k}=a(cidx{:}); % use comma-separated list syntax
end
