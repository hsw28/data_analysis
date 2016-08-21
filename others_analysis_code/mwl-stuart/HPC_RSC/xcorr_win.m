function [c, lags] = xcorr_win(x, y, winIdx, maxLag, scaleOpt)
if nargin < 5
    scaleOpt = 'none';
end

if ~all(size(x) == size(y))
    error('Input vectors X and Y must be the same size');
end

if ~isvector(x) || ~isvector(y);
    error('The inputs x and y must be vectors');
end

if ~isvector(winIdx) || ~ismonotonic(winIdx) 
    error('winIdx must be a 1xM vector of monotonically increasing indecies');
end

if ~isscalar(maxLag) || maxLag < 1
    error('maxLag must be a scalar greater than or equal to 1');
end

if isrow(winIdx)
    winIdx = winIdx';
end

if ~ischar(scaleOpt) || ~any( strcmp(scaleOpt, {'none', 'biased', 'coeff', 'unbiased'}))
    error('scaleOpt must be one of: none, biased, unbiased, coeff'); 
end

nLag = maxLag*2 + 1;
lags = -maxLag:maxLag;

% 
% c = nan(nLag,1);
% for i = 1:nLag
% 
%     c(i) = sum( conj( x(winIdx) ) .* y(winIdx - lags(i)) );
% end
    
xIdx = repmat(winIdx, 1, nLag);
yIdx = bsxfun(@minus, xIdx, lags);

% yIdx = bsxfun(@minus, winIdx, lags);


switch scaleOpt
    case 'none'
        c = calc_xcorr(x,y, xIdx, yIdx);
    case 'biased'
    case 'unbiased'
    case 'coeff'
        xScale = sqrt( calc_xcorr(x,winIdx));
        yScale = sqrt( calc_xcorr(y,winIdx));
        
        c = calc_xcorr(x./xScale, y./yScale, xIdx, yIdx);
        
end
% c = sum(c);


end


function c = calc_xcorr(x, y, winX, winY)
    
    % calc acorr
    if nargin == 2
         c = sum( conj( x(y)) .* x(y) );
    % calc xcorr
    elseif nargin ==4
        c = sum( conj( x(winX)) .* y(winY) );
    end
end