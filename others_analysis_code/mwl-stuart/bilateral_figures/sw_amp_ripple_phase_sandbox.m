nRipple = numel(r.peakIdx);

figure;

subplot(311);

 

for i = 1:nRipple

    line(mod(angle(hilbert(r.sw{1}(i,:))),2*pi), abs(hilbert(r.rip{1}(i,:))), 'linestyle', 'none', 'marker', '.','markersize', 5)

end

title('Trig-Trig');

 

subplot(312);

for i = 1:nRipple

    line(mod(angle(hilbert(r.sw{1}(i,:))),2*pi), abs(hilbert(r.rip{2}(i,:))), 'linestyle', 'none', 'marker', '.','markersize', 5)

end

title('Trig-Ipsi');

 

subplot(313);

for i = 1:nRipple

    line(mod(angle(hilbert(r.sw{1}(i,:))),2*pi), abs(hilbert(r.rip{3}(i,:))), 'linestyle', 'none', 'marker', '.','markersize', 5)

end

title('Trig-Cont');

 

set(get(gcf,'Children'),'Xlim', [0 2*pi]);

 

%%

 

bins = {linspace(0, 250, 50), linspace(0,2*pi,20)};

 

X = mod(angle(hilbert(r.sw{1}')),2*pi);

Y1 = abs(hilbert(r.rip{1}'));

Y2 = abs(hilbert(r.rip{2}'));

Y3 = abs(hilbert(r.rip{3}'));

 

h1 = hist3([Y1(:),X(:)], bins);

h2 = hist3([Y2(:),X(:)], bins);

h3 = hist3([Y3(:),X(:)], bins);

 

figure('Position', [593    50   470   636]);

subplot(311);

imagesc(bins{2}, bins{1}, log(h1) );

 

subplot(312);

imagesc(bins{2}, bins{1}, log(h2) );

 

subplot(313);

imagesc(bins{2}, bins{1}, log(h3) );

 

set(get(gcf,'Children'),'YDir', 'normal',...

    'Xtick', 0:pi/2:(2*pi), 'XtickLabel', {'0', '1/2 pi', 'pi', '3/2 pi', '2 pi'}, 'fontsize', 14);

 

%%

%%

 

bins = {linspace(0, 250, 50), linspace(0,2*pi,20)};

 

X = mod(angle(hilbert(r.sw{1}')),2*pi);

Y1 = abs(hilbert(r.rip{1}'));

Y2 = abs(hilbert(r.rip{2}'));

Y3 = abs(hilbert(r.rip{3}'));

 

 

randIdx = randsample(size(X,2), size(X,2) );

X2 = X(:, randIdx);

h1 = hist3([Y1(:),X2(:)], bins);

h2 = hist3([Y2(:),X2(:)], bins);

h3 = hist3([Y3(:),X2(:)], bins);

 

figure('Position', [593    50   470   636]);

subplot(311);

imagesc(bins{2}, bins{1}, log(h1) );

 

subplot(312);

imagesc(bins{2}, bins{1}, log(h2) );

 

subplot(313);

imagesc(bins{2}, bins{1}, log(h3) );

 

set(get(gcf,'Children'),'YDir', 'normal',...

    'Xtick', 0:pi/2:(2*pi), 'XtickLabel', {'0', '1/2 pi', 'pi', '3/2 pi', '2 pi'}, 'fontsize', 14);

 

%%

figure;

subplot(121);

line(X(:), Y3(:),'marker','.', 'linestyle', '.', 'markersize', 1);

xlabel('Phase A', 'fontsize', 14);

ylabel('Envelope B', 'fontsize', 14)

title('Real Data', 'fontsize', 14);

 

subplot(122);

line(X2(:), Y3(:),'marker','.', 'linestyle', '.', 'markersize', 1);

xlabel('Phase A', 'fontsize', 14);

ylabel('Envelope B', 'fontsize', 14)

title('Shuffled Phase', 'fontsize', 14);

 

set(get(gcf,'Children'),'YDir', 'normal', 'XLim', [0 2*pi],...

    'Xtick', 0:pi/2:(2*pi), 'XtickLabel', {'0', '1/2 pi', 'pi', '3/2 pi', '2 pi'}, 'fontsize', 14);



