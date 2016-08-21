function [Lr,L]=lratio(D2,df,clusters)
%LRATIO compute Lratio cluster quality measure
%
%  lr=LRATIO(distances,nfeatures) computes the Lratio measure for the
%  vector of distances and given the number of features that were used to
%  calculate the distances.
%
%  lr=LRATIO(distances,nfeatures,clusters) computes the Lratio measure for
%  every cluster.
%
%  [lr,l]=LRATIO(...) also returns the L measure, not normalized to the
%  size of the cluster.
%

%check arguments
if nargin<2
  help(mfilename)
  return
end

if nargin<3
  L = sum( 1-chi2cdf(D2(:),df) );
  Lr = L./ numel(D2);
else
  for k=1:numel(clusters)
    idx = setdiff( 1:size(D2,1), clusters{k} );
    L(k) = sum( 1-chi2cdf(D2(idx,k),df) );
    Lr(k) = L(k)./ numel(clusters{k});
  end
end