function [xs,ys] = trode_draw_locations(varargin)

p = inputParser();
p.addParamValue('feducial_markers',[2 5; -3.5 -5.5]);
p.addParamValue('xlim',[1.5, 6]);
p.addParamValue('ylim',[-6,-2]);
p.parse(varargin{:});
opt = p.Results;

disp(['Trace the pic of your drive bottom on transparency, plus feducial ',...
'marks, if you have any.  (if so, xs;ys go in ''feducial_markers''']);

fed_x = opt.feducial_markers(1,:);
fed_y = opt.feducial_markers(2,:);

slope = diff(fed_y)/diff(fed_x);
p1 = fed_x(1) + i*fed_y(1);
%p1 = [fed_x(1), fed_y(1)];
p2 = fed_x(2) + i*fed_y(2);
%p2 = [fed_x(2) + fed_y(2)];
v1 = p2 - p1;
v2 = [2.5];
v3 = v2 * (v1)/abs(v1);
p3 = [real(v3) + real(p1), imag(v3) + imag(p1)];
%p2 = abs(v3).*[cos(v3), sin(v3)]; + p1;
%v_p = dot(v1,v2) / sqrt( sum( v1.^2) );
%p3 = 


%x_range =  fed_x + 1.2*(fed_x - mean(fed_x));
%y_range =  fed_y + 1.2*(fed_y - mean(fed_y));


%fed_x = [fed_x, p3(1)];
%fed_y = [fed_y, p3(2)];

plot(fed_x,fed_y,'.'); hold on;
for n = 1:length(fed_x)
    text(fed_x(n), fed_y(n), [num2str(fed_x(n)),',',num2str(fed_y(n))]);
end

xlim(opt.xlim);
ylim(opt.ylim);

axis equal;

disp(['resize the plot, and flip and rotate the transparency to line up the feducial marks.',...
    'then, click all the trode locations in order 1:max_trode_num.  For a trode number w/ no physical trode,',...
    ' just click a nonsense point.  RET to finish.']);

%xlim([min(x_range), max(x_range)]);
%ylim([min(y_range), max(y_range)]);

[xs,ys] = getpts();

%xlim(sort(x_range));
%ylim(sort(y_range));

plot(xs,ys,'.');
for n = 1:length(xs)
      text(xs(n),ys(n),num2str(n));
end

assignin('base','trode_pos_xs',xs);
assignin('base','trode_pos_ys',ys);

disp(['Assigned points to trode_pos_xs, trode_pos_ys.  Copy em into ratname_rat_conv_table.m if they look right!']);
