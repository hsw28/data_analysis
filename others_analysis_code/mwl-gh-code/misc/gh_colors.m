function c = gh_colors(n)
% c = OUR_COLORS(n) return a color from a palette of several

palette = ...
   [...
    1   0.5  0.5; ...  % Ping
    1   0   0; ...  % Red
    0  .5   0; ...  % Green
    0   0   1; ...  % Blue
    1   1   0; ...  % Yellow
    0.5 0.5 0.5; ...  % Gray
    1   0   1; ...  % Magenta
    .5  0   0; ...  % Dark Red
    0   1   1; ...  % Cyan
    1  .5   0; ...  % Orange
    0  .5   1];     % Light Blue


c = palette(mod(n,size(palette,1)-1)+1, :);