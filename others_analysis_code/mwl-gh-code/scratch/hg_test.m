function f = hg_test()

f = figure; 

ax = axes('XLim',[-20,20],'YLim',[-20,20]);

x = linspace(0,2*pi,100);
y = sin(x);
h(1) = plot(x,y);
hold on;
h(2) = plot(x, 0 * ones(size(x)));
h(3) = plot([0,0], [-1,1]);

xlim([-8,8]);
axis equal

t = hgtransform('Parent',ax);
set(h,'Parent',t);


Mxy = eye(4);
Rxy = Mxy;
Txy = Mxy;
Sxy = Mxy;
Rxy = makehgtform('zrotate',2*pi/20);
Txy = makehgtform('translate',[1,4,0]);
Sxy = makehgtform('scale', [0.5, 2, 1]);

m = Txy * Rxy * Sxy



set(t,'Matrix',m);
plot2svg(['test.svg'],f);