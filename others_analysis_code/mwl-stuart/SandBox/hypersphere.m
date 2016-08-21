function Y = hypersphere(X,r=1) 
% compute the cartesian coordinates from the input 
% hypersphere angles and radius

% n = number of column vectors 
n = size(X,2);

% cosine terms 
C = [cos(X); ones(1,n)]; 
% sine terms 
S = [ones(1,n); cumprod(sin(X),1)]; 
% calculate output 
Y = r * C .* S;