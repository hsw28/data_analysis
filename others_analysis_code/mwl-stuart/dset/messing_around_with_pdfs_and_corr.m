x = -6:.5:6;
pdf1 = normpdf(x);

p = [];
p(:,1) = interp1(x, pdf1, linspace(-6, 0, 20), 'cubic', 0 );
p(:,2) = interp1(x, pdf1, linspace(-3, 3, 20), 'cubic', 0 );
p(:,3) = interp1(x, pdf1, linspace(0, 6, 20), 'cubic', 0 );
p(:,4) = interp1(x, pdf1, linspace(-4,8, 20), 'cubic', 0 );

c = corr(p);
for i=1:4
    c(i,i) = 0;
end
figure;
subplot(211);plot(p);
subplot(212);imagesc(c);


