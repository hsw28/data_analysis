x = rand(100,1);

tau = 4;
a = 1/tau;
xfilt = filtfilt(a, [1 a-1], x);


close all;
plot(x); hold on;
plot(xfilt,'r');

%%

clear x y;
x = 0:.05:2*pi;

y1 = zeros(size(x));
y2 =  mod(round(x / pi),2)*1.5 - .75;
y3 = .2 + .6 * sin(x);

close all;
plot(x,y1,x,y2,x,y3, 'linewidth', 4);
set(gca,'Box', 'off', 'YLim', [-1 1]);

xkcdify(gca);

%%

close all;
bar([ 3 2 4 6]);
%%
xkcdify(gca)
%%
close all;
boxplot(rand(20, 3) * 5);
xkcdify(gca)
%%

disp(' ');
a = gca;
c = get(gca,'Children');
disp( get(c, 'type'))
cc = get(c, 'Children');
disp( get(cc, 'type'))
