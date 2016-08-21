function [p, l] = error_area_plot(x, y, e, varargin)

args.parent = [];
args.smooth = 0;
args.smooth_n = 1;
args.smooth_dt = 1;

args = parseArgs(varargin, args);

ax  = axescheck(args.parent);

if isempty(ax)
    ax = axes('Parent', figure);
end
if ~isvector(x) || ~isvector(y) || ~isvector(e)
    error('X,Y, and E must all be vectors')
end


x = x(:)';
y = y(:)';
e = e(:)';

if args.smooth == 1
    y = smoothn(y, args.smooth_n, args.smooth_dt, 'correct', 1);
    e = smoothn(e, args.smooth_n, args.smooth_dt, 'correct', 1);
end;




X = [x fliplr(x)];
Y = [y+e fliplr(y-e)];

p = patch(X, Y, [0 0 .508], 'parent', ax);
l = line(x, y,  'parent', ax);


end

