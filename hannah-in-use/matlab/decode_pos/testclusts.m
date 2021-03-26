function f = testclusts(time, pos, clusters, tdecode, dim, decodedvel, varargin)


  pos4rank = pos;
  vel4rank = velocity(pos);

  clustname = (fieldnames(clusters));
  numclust = length(clustname);
  clustlist = [1:1:numclust];

  if length(cell2mat(varargin))>1
  output = {'cluster name'; 'mean'; 'median'; 'pval'; 'num'; 'pval w ranked'; 'num w ranked'};
  else
  output = {'cluster name'; 'mean'; 'median'; 'rank'; 'num'; 'pval w ranked'; 'num w ranked'};
  end

  %figure
  for k = 0:numclust

    if k == 0
    ridname = 'none'
    decoded = decodeshitPos(time, pos, clusters, tdecode, dim);


    else

    ridname = clustname(k);

    newclusts = rmfield(clusters,char(ridname));

    %for troubleshooting
    %ridname = char(ridname);
    %clust.new = clusters.(ridname);
    %[decoded bounds] = decodeshitPos_linear(time, pos, clust, tdecode, dim);
    %

    decoded = decodeshitPos(time, pos, newclusts, tdecode, dim);

    end



    error = decodederror(decoded, pos, tdecode);
    error_av = nanmean(error(1,:));
    error_med = nanmedian(error(1,:));


    [ranks pval]= velrankresults(pos4rank, vel4rank, decoded, vel4rank, dim, dim, 12, 0, 0);
    numpoint = length(ranks);

    [ranks2 pval2]= velrankresults(pos4rank, vel4rank, decoded, decodedvel, dim, dim, 12, 0, 0);
    numpoint2 = length(ranks);

    if length(cell2mat(varargin))>1
    [ranks pvalvel]= velrankresults(pos4rank, vel4rank, decoded, cell2mat(varargin), dim, dim, 12, 0, 0);
    newdata = {ridname; error_av; error_med; pval; numpoint; pvalvel};
    output = horzcat(output, newdata);
    else
    newdata = {ridname; error_av; error_med; pval; numpoint; pval2; numpoint2};

    output = horzcat(output, newdata);
    end

    %ranks = 0;
    %pval = 0;

    hold on
    subplot(numclust+1,1,k+1)
    scatter(decoded(1,:), decoded(2,:))

    %subplot(numclust+1, 1, k+1)
    %scatter(decoded(1,:), decoded(2,:))

    numclust-k
  end

  f = output';
