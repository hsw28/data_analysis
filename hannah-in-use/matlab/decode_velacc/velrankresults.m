function [f pval]= velrankresults(pos1, vel1, pos2, vel2, dimX, dimY, velthreshold, confidencethreshold, REM_YorN, varargin)
%REM_YorN: put 0 if not using REM, 1 if using REM)
%VARARGIN should be your bounds if using linear decoding

%{
if size(pos2,2)==4
  newpos = NaN(length(pos2),3);
  newpos(:,1) = pos2(4,:);
  newpos(:,2) = pos2(1,:);
  newpos(:,3) = pos2(2,:);
  pos2 = newpos;
end
if size(pos1,2)==4
  newpos = NaN(length(pos1),3);
  newpos(:,1) = pos1(4,:);
  newpos(:,2) = pos1(1,:);
  newpos(:,3) = pos1(2,:);
  pos1 = newpos;
end

if size(vel2,1)==3
  newvel = vel2([1,3],:);
  vel2 = newvel;
end

if size(vel1,1)==3
  newvel = vel1([1,3],:);
  vel1 = newvel;
end
%}


  if size(vel1,1) == 2
    vel1(1,:) = smoothdata(vel1(1,:), 'gaussian', 30);
    vel1OLD = vel1;
    vel1 = vel1(:,vel1(1,:)>velthreshold);
    size(vel1);
    if REM_YorN == 0
      assvel = assignvelOLD(vel2(2,:), vel1OLD);
      goodvel = find(assvel>velthreshold);
      vel2 = vel2(:,goodvel);
    end
  end

rank1 = velrank(pos1, vel1, dimX, dimY, confidencethreshold, varargin);
rank2 = velrank(pos2, vel2, dimX, dimY, confidencethreshold, varargin);


rank1.order = sortrows(rank1.order, 2);
rank2.order = sortrows(rank2.order, 2);


if length(rank2.order)==0
  warning('YOU HAVE NO OVERLAP DECODING')
end

good = find(~isnan(rank1.order(:, 3)));
rank1 = rank1.order(good,:);
rank2 = rank2.order(good,:);
good = find(~isnan(rank2(:, 3)));
rank1 = rank1(good,:);
rank2 = rank2(good,:);
%good = find(rank1(:,3)>7);
%rank1 = rank1(good,:);
%rank2 = rank2(good,:);
%good = find(rank2(:,3)>7);
%rank1 = rank1(good,:);
%rank2 = rank2(good,:);


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



%coeffs = polyfit(x, y, 1);
%polydata = polyval(coeffs,x);
%sstot = sum((y - mean(y)).^2);
%ssres = sum((y - polydata).^2);
%rsquared = 1 - (ssres / sstot)
%stats = fitlm(x,y);
%pval = stats.Coefficients.pValue(2)


%scatter(x, y);
[rho,pval] = corr(x,y, 'Type','Spearman')
str1 = {'Spearmans rho' rho, 'P value' pval};
%[rho,pval] = corr(x,y,'Type','Kendall')
%str2 = {'Kendalls rho' rho, 'P value' pval};
xlabel('Actual Position Rank from Slowest Average Speed to Fastest')
ylabel('Decoded Position Rank from Slowest Average Decoded Speed to Fastest')
text(1.2,max(y)*.9,str1);
%text(1.2,max(y)*.7,str2);

%gkgammatst([x,y], .05, 1)
