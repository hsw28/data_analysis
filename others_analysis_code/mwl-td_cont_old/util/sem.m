function s = sem(X)
% SEM calculate the standard error of the mean of the samples in X (columnwise)
  
  s = std(X,0,1)./sqrt(size(X,1));