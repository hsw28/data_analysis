function [y,m]=mmrepeat(x,n)
%MMREPEAT Repeat or count repeated values in a vector.
%
%  y=MMREPEAT(x,n) returns a vector formed from x where x(i) is repeated
%  n(i) times. If n is a scalar it is applied to all elements of x. n
%  must contain nonnegative integers. n must be a scalar or have the same
%  length as x.
%
%  [x,n]=MMREPEAT(y) counts the consecutive repeated values in y returning
%  the values in x and the counts in n. y=mmrepeat(x,n) and [x,n]=mmrepeat(y)
%  are inverses of each other if n contains no zeros and x contains unique
%  elements.
%
%  Example
%    mmrepeat([1 2 3 4],[2 3 1 0]) %returns the vector
%    %[1 1  2 2 2  3]    (extra spaces added for clarity)
%
%
%  See also MMSUBDIV

% D.C. Hanselman, University of Maine, Orono, ME 04469
% 3/2/99, 4/14/99
% Mastering MATLAB 6, Prentice Hall, ISBN 0-13-019468-9

if nargin==2 % MMREPEAT(X,N)
   xlen=length(x);
   nlen=length(n);
   if ndims(x)~=2 || numel(x)~=xlen
      error('mmrepeat:invalidArgument', 'x must be a vector.')
   else
      [r,c]=size(x);
   end
   if any(n<0) || any(fix(n)~=n)
      error('mmrepeat:invalidArgument', 'n must contain nonnegative integers.')
   end
   if ndims(n)~=2 || numel(n)~=nlen || (nlen>1 && nlen~=xlen)
      error('mmrepeat:invalidArgument', 'n must be a scalar or vector the same size as x.')
   end
   x=reshape(x,1,xlen); % make x a row vector
   
   if nlen==1 % scalar n case, repeat all elements the same amount
      if n<=0 % quick exit for special case
         y=[];
         return
      end
      y=x(ones(1,n),:); % duplicate x to make n rows each containing x
      y=y(:);           % stack each column into a single column
      if r==1           % input was a row so return a row
         y=y.';
      end
   else % vector n case
      iz=find(n>0);        % look at positive repeats only
      x=x(iz);
      n=n(iz);
      csn=cumsum(n); 
      y=zeros(1,csn(end)); % preallocate temp/output variable
      y(csn(1:end-1)+1)=1; % mark indices where values increment
      y(1)=1;              % poke in first index
      y=x(cumsum(y));      % use cumsum to set indices
      if c==1              % input was a column so return a column
         y=y.';
      end
   end
elseif nargin==1 % MMREPEAT(Y)
   xlen=length(x);
   if ndims(x)~=2 || numel(x)~=xlen
      error('mmrepeat:invalidArgument','y must be a vector.')
   else
      [r,c]=size(x); %#ok
   end
   x=reshape(x,1,xlen); % make x a row vector
   xnan=isnan(x);
   xinf=isinf(x);
   if any(xnan|xinf) % handle case with exceptions
      ntmp=sum(rand(1,4))*sqrt(realmax); % replacement for nan's
      itmp=1/ntmp;                       % replacement for inf's
      x(xnan)=ntmp;
      x(xinf)=itmp.*sign(x(xinf));
      y=[1 diff(x)]~=0;         % places where distinct values begin
      m=diff([find(y) xlen+1]); % counts
      x(xnan)=nan;              % poke nan's and inf's back in
      x(xinf)=inf*x(xinf);
      
   else % x contains only algebraic numbers
      y=[1 diff(x)]~=0;         % places where distinct values begin
      m=diff([find(y) xlen+1]); % counts 
   end
   y=x(y); % the unique values
   if c==1
      y=y.';
      m=m.';
   end
else
   error('mmrepeat:invalidArgument','Incorrect Number of Input Arguments.')
end
