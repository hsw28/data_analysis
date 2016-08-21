function d = randdist( fcn, rdata, n, fcn_args, perm_fcn)
%RANDDIST will compute the randomization distribution
%
%  d=RANDDIST(fcn,data) returns the randomization distribution by calling
%  the function fcn 1000 times with random row permutations of data. The
%  function should return a scalar.
%
%  d=RANDDIST(fcn,data,n) performs n permutations.
%
%  d=RANDDIST(fcn,data,n,argin) provides a cell array of extra arguments
%  to the function.
%
%  d=RANDDIST(fcn,data,n,argin,permfcn) uses a custom permutation
%  function that takes data as input and returns a permuted (randomized)
%  version of data.
%


%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<2
    help(mfilename)
    return
end

if nargin<3 || isempty(n)
    n = 1000;
end

if nargin==3 && iscell(n)
    fcn_args = n;
    n = 1000;
elseif nargin==3 && isa(n, 'function_handle')
    perm_fcn = n;
    n = 1000;
    fcn_args = {};
elseif nargin==4 && isa(fcn_args, 'function_handle')
    perm_fcn = fcn_args;
    fcn_args = {};
elseif nargin<5
    perm_fcn = [];
    fcn_args = {};
end


if isempty( perm_fcn )

    nr = size(rdata,1);

    %calculate all possible permutations for small sizes
    if nr<10
        p = perms(1:nr);
        n = min( factorial(nr), n );
        for k=1:n
            %call function
            d(k,1) = fcn( rdata( p(k,:), : ), fcn_args{:} );
        end

    else

        for k=1:n
            %call function
            p = randperm( nr );
            d(k,1) = fcn( rdata( p, : ), fcn_args{:} );
        end

    end

else

    for k=1:n
        d(k,1) = fcn(  perm_fcn( rdata ), fcn_args{:} );
    end
    
end

d = sort(d);
