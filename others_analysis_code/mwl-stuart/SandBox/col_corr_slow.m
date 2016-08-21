function [c] = col_corr_slow(A, B, varargin)
%COL_CORR compute the column by column correalion between two matrices
% C=COL_CORR(A, B) computes the correlation for each set of columns in A
% and B of identical size
%
% This function is basically a wrapper around diag( corr( A,B )) except
% that the matrices that diag(corr()) can accept are limited in size, this
% function breaks up the input matrices and computers the column by column
% correlation piece by piece.  This is much slower than col_corr
%
% See also diag corr col_corr


% Copyright Stuart Layton


args.maxColPerCalc = 2000;
args = parseArgs(varargin, args);

% Check the inputs
if ~all(size(A) == size(B))
    error('A and B must be the same size');
end

% The simplest way to compute the column by column correlation is with:
% diag( corr( A, B ) );
% but this won't work when A and B are big as it will require a huge
% matrix
% 
% instead i'm going to cut it up into smaller chunks and try to compute the
% chunk by chunk and then combine the results in the end.

[nRow nCol] = size(A);

maxColPerCalc = args.maxColPerCalc; %

%% 
c = zeros(1,nCol);

% Split into even chunks for the loop, if the division isn't clean the
% remaining values will get calculated after the loop

nCalc = floor (nCol / maxColPerCalc); 
nRemaining = nCol - nCalc * maxColPerCalc;

for i=1:nCalc
    idx1 = (i-1) * maxColPerCalc +1;
    idx2 = i*maxColPerCalc;
    %disp(['Calculating:', num2str(idx1), '->', num2str(idx2)]);
     c( idx1:idx2 ) = diag( ...
        corr( ...
            A( : , idx1:idx2 ), B( : , idx1:idx2 ) ) );
end

if (nRemaining>0)
    idx1 = nCalc * maxColPerCalc + 1;
    idx2 = idx1 + nRemaining - 1;
    
    %disp(['Calculating:', num2str(idx1), '->', num2str(idx2)]);
    
    c( idx1:idx2 ) = diag( ...
        corr( ...
            A( : , idx1:idx2 ), B( : , idx1:idx2 ) ) );
end
    

