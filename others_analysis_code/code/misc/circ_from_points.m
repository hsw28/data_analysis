function [x_center,y_center,r] = circ_from_points(xs,ys,varargin)

p = inputParser();
p.addParamValue('n_tests',0);
p.addParamValue('draw_intermediates',false);
p.addParamValue('draw_final',false);
p.addParamValue('n_test_points', 50);
p.addParamValue('rad_mean_and_var', [10, 2]);
p.addParamValue('use_test_data', false);
p.addParamValue('perturb_first_guess',false); % For testing
p.parse(varargin{:});
opt = p.Results;

% lfun_test_initial_guess();  % looks good!
if(opt.use_test_data)
    [xs,ys] = lfun_generate_test_data( opt.rad_mean_and_var(1), ...
        opt.rad_mean_and_var(2), opt.n_test_points );
end


[x_center,y_center,r] = lfun_initial_guess( xs,ys );
if (opt.perturb_first_guess)
    x_center = x_center + 50;
    y_center = y_center + 5;
    r = r - 4;
end

n_iterations = 5;

for n = 1:n_iterations
    [x_center,y_center] = lfun_optimize_pos( xs,ys,x_center,y_center,r );
    r = lfun_optimize_rad( xs,ys,x_center,y_center,r );
    if(opt.draw_intermediates || (opt.draw_final && n == n_iterations) )
        hold off
        draw_circle(x_center,y_center,r);
        hold on;
        plot(xs,ys,'.');
        axis equal;
        title(num2str(n));
        xlim([-20 20]);
        ylim([-20 20]);
        pause(0.1);
    end
end

end

function [xs,ys] = lfun_generate_test_data (test_rad_mean, test_rad_var, test_n_pts )
th = rand(1,test_n_pts) * 2 * pi;
r = test_rad_mean + randn(1,test_n_pts) .* test_rad_var;
xs = r .* cos(th) + 10 * rand(1);
ys = r .* sin(th) + 10 * rand(1);
end


function [xs,ys] = lfun_take3(xs_in,ys_in)
xs(1) = xs_in(1); % take first point from input
ys(1) = ys_in(1);
dists = sqrt( (xs(1) - xs_in) .^ 2 + (ys(1) - ys_in) .^ 2);
xs(2) = xs_in(find(dists == max(dists),1)); % and take the furthest from that
ys(2) = ys_in(find(dists == max(dists),1));
xs_in = xs_in(2:end);  % drop the first point from the list of candidates
ys_in = ys_in(2:end);
dists = dists(2:end);
dists2 = sqrt( (xs(2) - xs_in) .^ 2 + (ys(2) - ys_in) .^ 2);
dist_score = 1 ./ (1 ./ dists + 1 ./ dists2);  % Find a third point far from these 2
xs(3) = xs_in(find(dist_score == max(dist_score),1));
ys(3) = ys_in(find(dist_score == max(dist_score),1));
end


% Deterministic model from 3 points
function [x_center, y_center, r] = lfun_initial_guess(xs_in,ys_in)
[xs,ys] = lfun_take3(xs_in, ys_in);
[x1,y1,m1] = normal_of_seg( xs(1), xs(2), ys(1), ys(2) );
[x2,y2,m2] = normal_of_seg( xs(2), xs(3), ys(2), ys(3) );
[x_center,y_center] = intersect_of_lines( x1, y1, m1, x2, y2, m2 );
r = sqrt ( (x_center - xs(1))^2 + (y_center - ys(1))^2 );
end

function [x,y] = intersect_of_lines( x1, y1, m1, x2, y2, m2 )
x = ((-m1) * x1 + y1 + m2 * x2 - y2) / (m2 - m1);
y = (y2/m2 - x2 + x1 - y1/m1) / (1/m2 - 1/m1);
end

function [x0,y0,m] = normal_of_seg(x1,x2,y1,y2)
seg_m = (y2 - y1) / (x2 - x1);
m = -1/seg_m;
x0 = mean([x2,x1]);
y0 = mean([y2,y1]);
end


% Model fit
function score = lfun_score( xs,ys, center_x, center_y, r )
rs_squared = (xs - center_x).^2 + (ys - center_y).^2;
score = sum ((rs_squared - r.^2 ) .^2 );
end


% Optimize position
function [best_center_x, best_center_y] = lfun_optimize_pos(xs,ys, x0, y0, r0)
scale_fracs = 10 ./ [1, 10, 100 1000 10000];
n_test_pts = 10;
best_center_x = x0;
best_center_y = y0;
x_range = max(xs) - min(xs);
y_range = max(ys) - min(ys);
for s = 1 : numel(scale_fracs)
    x_test = (linspace (-1, 1, n_test_pts)) .* scale_fracs(s) .* x_range + best_center_x;
    y_test = (linspace (-1, 1, n_test_pts)) .* scale_fracs(s) .* y_range + best_center_y;
    [X_TEST,Y_TEST] = meshgrid(x_test,y_test);
    test_vals = mat2cell( cat(3, X_TEST, Y_TEST), ones(1,n_test_pts), ones(1,n_test_pts), 2 );
    scores = cellfun( (@(v)  lfun_score(xs,ys, v(1), v(2), r0)), test_vals);
    best_test_pt = test_vals{find (scores == min(min(scores)), 1)};
    best_center_x = best_test_pt(1);
    best_center_y = best_test_pt(2);
end
end

% Optimize radius
function best_r = lfun_optimize_rad(xs,ys,x0,y0,r0)
scale_fracs = 1 ./ [1 2 4 8 16];
n_test_pts = 10;
best_rad = r0;
for s = 1 : numel(scale_fracs)
    r_test = (linspace (-0.5, 4, n_test_pts)) .* scale_fracs(s) .* best_rad + best_rad;
    scores = arrayfun( (@(x) lfun_score( xs, ys, x0, y0, x )), r_test);
    best_r = r_test(find( scores == min(scores), 1));
end
end

function b = lfun_test_initial_guess()
%x_test = 1
%y_test = 2
%r_test = 10
%xs = r_test .* [cos(0), cos(2*pi/3), cos(4*pi/3)] + x_test
%ys = r_test .* [sin(0), sin(2*pi/3), sin(4*pi/3)] + y_test
xs = rand(1,30);
ys = rand(1,30);
[x_center,y_center,r] = lfun_initial_guess(xs,ys)
draw_circle(x_center,y_center,r);
hold on;
[xs_3,ys_3] = lfun_take3(xs,ys);
axis equal;
plot(xs_3,ys_3,'.');
end

function a = draw_circle (x,y,r)
s = 0:0.1:(2*pi);
a = plot( r*cos(s)+x, r*sin(s)+y );
end