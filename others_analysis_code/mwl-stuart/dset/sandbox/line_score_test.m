pdf = diag(ones(5,1) ,0);

pdf(1,5) = .3750;
pdf(2,4) = .3750;
pdf(4,2) = .3750;
pdf(5,1) = .3750;

tbins = 1:5;
pbins = 1:5;
% 
% slope = 1;
% intercept = 0;

slope = -1;
intercept = 6;

figure; 
imagesc(tbins, pbins, pdf); set(gca,'YDir', 'normal');
yPts = slope * tbins + intercept;
line(tbins, yPts, 'color', 'w');

compute_line_score(tbins(:), pbins(:), pdf, slope, intercept)

%%

m = ones(3,10);

m(1,:) = 1;
m(2,:) = 3;
m(3,:) = 5;


x = (1:10)';
y = ones(size(x))*2;

m(sub2ind(size(m),y,x))