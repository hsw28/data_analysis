function f = velrankresults(pos1, vel1, pos2, vel2, dimX, dimY)

rank1 = velrank(pos1, vel1, dimX, dimY);
rank2 = velrank(pos2, vel2, dimX, dimY);

rank1.order = sortrows(rank1.order, 2);
rank2.order = sortrows(rank2.order, 2);

good = find(~isnan(rank1.order(:, 3)));
rank1 = rank1.order(good,:);
rank2 = rank2.order(good,:);
good = find(~isnan(rank2(:, 3)));
rank1 = rank1(good,:);
rank2 = rank2(good,:);


rank1 = sortrows(rank1, 3);
rank2 = sortrows(rank2, 3);
%num = find(~isnan(rank2(:, 3)));
neworder = [1:1:length(rank1)];
newrank1 = [neworder', rank1(:, 2:4)];
newrank2 = [neworder', rank2(:, 2:4)];
rank1 = sortrows(newrank1, 2);
rank2 = sortrows(newrank2, 2);

%f = [rank1, rank2];


x = rank1(:,1);
y = rank2(:,1);
%good = find(~isnan(x));
%x = x(good);
%y = y(good);
%good = find(~isnan(y));
%x = x(good);
%y = y(good);

f = [rank1, rank2];


[rho,pval] = corr(x,y, 'Type','Spearman')

%coeffs = polyfit(x, y, 1);
%polydata = polyval(coeffs,x);
%sstot = sum((y - mean(y)).^2);
%ssres = sum((y - polydata).^2);
%rsquared = 1 - (ssres / sstot)
%stats = fitlm(x,y);
%pval = stats.Coefficients.pValue(2)

figure
scatter(x, y);
str1 = {'Spearmans rho' rho, 'P value' pval};
text(1.2,max(y)*.9,str1);
