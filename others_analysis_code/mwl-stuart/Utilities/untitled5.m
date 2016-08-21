x = randn(1200,1) * 10 + 190;
y = randn(1200,1) * 10 + 190;

x2 = [x; randn(800,1) * 10 + 180];
y2 = [y; randn(800,1) * 10 + 180];



close all
plot(x2,y2,'.', x,y,'r.');

bins = 150:2.5:225;

occ = hist3([x2,y2], {bins, bins});
imagesc(bins, bins, occ);
set(gca,'YDir', 'normal')

%%


figure;

for i = 1:numel(ripples.sleep)
    r = ripples.sleep(i);
    plot(r.window, mean(r.raw{1}), r.window, mean(r.raw{3}));
    disp(i);
    pause;
    
end