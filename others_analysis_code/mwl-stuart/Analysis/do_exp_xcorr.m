function data = do_exp_xcorr(exp, varargin)

epochs = exp.epochs;
for i = epochs
    ep = i{1};

    [c e t] = cluster_xcorr(exp.(ep).clusters, varargin);
    
    data.(ep).clusters_xcorr.corr = c;
    data.(ep).clusters_xcorr.event = e;
    data.(ep).clusters_xcorr.trig = t;
    
    f = figure;
    a = gca();
    display_cluster_corr(c, e, t, a);
    title(['Cluster XCorr', ep]);
end


end