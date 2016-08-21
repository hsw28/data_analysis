function [bps bps2] = bitsperspike(tc)
% taken from Skaggs 1993 - An information-theoretic approach to deciphering the hippocampal code

% normalize tuning curves by mean firing rate
tc = bsxfun(@rdivide, tc, mean(tc));

% compute total information than divide by field size
bps = sum(  tc .* log2( tc ) ) / size(tc,1);
    
