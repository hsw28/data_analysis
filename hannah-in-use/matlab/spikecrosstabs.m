function f = spikecrosstabs(infomatrix, varargin)
  % infomatrix is the matrix of all info you want to compare
  % number of cells should be first dimension
  % then input the number you want to be the dividing line. if you want an absolute value (for example, no change = 1, decrease <1, increaae >1, and you want to see any time the cell changes firing but you dont care which direction), you have to normalize data around baseline value first
  % so table abs(amount-1) BEFORE entering data
  % ALSO MAKE SURE FOR CORR TO MAKE R2 VALUES OF 1 == NaN

line = cell2mat(varargin);
numattributes = size(infomatrix, 2);
numcells = size(infomatrix, 1);
k = 1;

%going through and figuring out below or above thresholds
while k<=numattributes
  %infomatrix(:,k);
  divide = line(:,k);
  for i = 1:numcells
      if infomatrix(i,k) < divide
        infomatrix(i,k) = 0;
      elseif infomatrix(i,k) == Inf
        infomatrix(i,k) = NaN;
      elseif infomatrix(i,k) >= divide
        infomatrix(i,k) = 1;

      end
  end
k = k+1;
end
infomatrix;

q=1;
m = {'compare'; 'Chi p value'; 'Fisher Test p value'; 'Fisher Odds Ratio'};
while q <= numattributes
  poppercentbelow = length(find(infomatrix(:,q)=='b'))/numcells;
  for z =  q+1:numattributes
      [tbl,chi2,p,labels] = crosstab(infomatrix(:,q), infomatrix(:,z));
      [h,tp,stats] = fishertest(tbl);
      % convert to percents
      %tbl = tbl./numcells;
      x = [num2str(q), ' X ', num2str(z)];
      new = {x; p; tp; stats.OddsRatio}; ;
      m = horzcat(m, new);

  end
q = q+1;
end

f= m';
