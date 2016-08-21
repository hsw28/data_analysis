function tc = get_tuning_curves(exp, epoch)

    clusters = exp.(epoch).clusters;

    tc = nan(length(clusters(1).tc1), length(clusters),2);

    for i=1:length(clusters)
        tc(:,i,1) = clusters(i).tc1(:);
        tc(:,i,2) = clusters(i).tc2(:);
    end
    %tc = tc+.001;

end