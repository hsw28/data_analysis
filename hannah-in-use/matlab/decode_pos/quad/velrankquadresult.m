function f = velrankquadresult(pos1, vel1, pos2, vel2, decodet, velthreshold, REM_YorN)
%REM_YorN: put 0 if not using REM, 1 if using REM




if size(vel1,1) == 2
  vel1(1,:) = smoothdata(vel1(1,:), 'gaussian', 15);
  vel1OLD = vel1;
  vel1 = vel1(:,vel1(1,:)>velthreshold);
  if REM_YorN == 0
    assvel = assignvelOLD(vel2(2,:), vel1OLD);
    goodvel = find(assvel>velthreshold);
    vel2 = vel2(:,goodvel);
  end
end




  rank1 = velrankquad(pos1, vel1, decodet);
  rank2 = velrankquad(pos2, vel2, decodet);



  rank1.order = sortrows(rank1.order, 2);
  rank2.order = sortrows(rank2.order, 2);

  if length(rank2.order)==0
    warning('YOU HAVE NO OVERLAP DECODING')
  end

  good = find(~isnan(rank1.order(:, 3)));
  rank1 = rank1.order(good,:);
  rank2 = rank2.order(good,:);
  good = find(~isnan(rank2(:, 3)));
  rank1 = rank1(good,:)
  rank2 = rank2(good,:)
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
