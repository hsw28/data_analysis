clear x y x2 y2 x3 y3;
np =10;
x{1} = linspace(1,-1,np);
y{1} = ones(1,np);

x{2} = ones(1,np) * -1;
y{2} = linspace(1,-1,np);

x{3} = linspace(-1,1,np) * -1;
y{3} = ones(1,np) * -1;

x{4} = ones(1,np);
y{4} = linspace(-1,1,np) * -1;

for i=1:numel(x)
    [x2{i},y2{i}] = square2circle(x{i}, y{i}, 0,0);
    [x3{i},y3{i}] = circle2square(x2{i},y2{i},0,0);
end

c = 'rmkc';
figure; 
axes;

for i=1:numel(x)
    line( x{i},  y{i}, 'linestyle', 'none', 'marker', 'o', 'markersize', 25, 'color', c(i));
    line(x2{i}, y2{i},'linestyle', 'none', 'marker', '+', 'markersize', 15, 'color', c(i));
    line(x3{i}, y3{i},'linestyle', 'none', 'marker', '.', 'markersize', 25, 'color', c(i));
end


%%
a = rand(700,1)-.5;
b = rand(700,1)-.5;


[ac bc] = square2circle(a, b, 0,0);
[as bs] = circle2square(ac,bc,0,0);

figure;
subplot(311);
plot(a,b,'.');

subplot(312);
plot(ac,bc,'.');

subplot(313);
plot(as,bs,'.');
linkaxes();
set(gca,'Xlim', [-.7 .7], 'YLim', [-.7 .7]);



