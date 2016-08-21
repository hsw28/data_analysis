function data =compare_ave_firing_rates(exp, varargin)

args.epochs = exp.epochs;
args.plot_rates = 1;
args = parseArgs(varargin, args);
args.ind_ignore = [];


data = struct;
for ep = args.epochs
    e = ep{:};
    

    if ~isfield(exp.(e).clusters, 'mean_rate_run')
        disp('Cluster stats not computed, computing them now')
        exp = process_experiment(exp, 'operations', 'clusters_stats');
    end
    
    %% Peak PF firing rate
    
    exp.(e).clusters = check_for_interneurons(exp.(e).clusters);
    
    data.(e).max_fr.dir1 = cellfun(@max, {exp.(e).clusters.tc1});
    data.(e).max_fr.dir2 = cellfun(@max, {exp.(e).clusters.tc2});
    
    
    
    data.(e).max_fr.max = max([ data.(e).max_fr.dir1 ; data.(e).max_fr.dir2]);
    data.(e).max_fr.mean = mean( data.(e).max_fr.max ) ;
    data.(e).max_fr.std = std( data.(e).max_fr.max );
    data.(e).max_fr.sem = data.(e).max_fr.std ./ sqrt( numel(data.(e).max_fr.max));
    
    %% Running Mean FR
    data.(e).run_fr.rates = cell2mat({exp.(e).clusters.mean_rate_run});
    
    data.(e).run_fr.mean = mean(data.(e).run_fr.rates);
    data.(e).run_fr.std = std(data.(e).run_fr.rates);
    data.(e).run_fr.sem = data.(e).run_fr.std ./ sqrt( numel(data.(e).run_fr.rates));
    
    
    
    %% Stop Mean FR
    data.(e).stop_fr.rates = cell2mat({exp.(e).clusters.mean_rate_stop});
    data.(e).stop_fr.mean = mean(data.(e).stop_fr.rates);
    data.(e).stop_fr.std = std(data.(e).stop_fr.rates);
    data.(e).stop_fr.sem = data.(e).stop_fr.std ./ sqrt( numel(data.(e).stop_fr.rates));
    
end

if args.plot_rates
    plot_rates(data, args.epochs);
end
end


function plot_rates(data, epochs)
    i = 0;
    x = [];
    fr = [];
    std = [];
    
    for ep = epochs;
        e = ep{:};
        i = i+1;
        x(i) = i;
        fr(i) = data.(e).max_fr.mean;
        std(i) = data.(e).max_fr.sem;
    end
    
    for ep = epochs;
        e = ep{:};
        i = i+1;
        x(i) = i;
        fr(i) = data.(e).run_fr.mean;
        std(i) = data.(e).run_fr.sem;
    end
    
    for ep = epochs;
        e = ep{:};
        i = i+1;
        x(i) = i;
        fr(i) = data.(e).stop_fr.mean;
        std(i) = data.(e).stop_fr.sem;
    end
    figure;
    
    fr = reshape(fr, numel(epochs),3)';
    std =reshape(std, numel(epochs),3)';
    size(fr)
    %x_bar = [1 1.1; 2 2.1; 3 3.1];
    %x_err = [.95 1.25; 2 2.35; 2.9 3.25];
    subplot(131);
    barerrorbar([1 1.1], fr(1,:)', std(1,:), {'grouped'}, {'*r'});
    set(gca, 'Xlim', [.925 1.175], 'Xtick', []);
    subplot(1,3,2:3);
    barerrorbar([1 1.1; 1.3 1.4], fr(2:3,:), std(2:3,:), {'grouped'}, {'*r'});
    set(gca, 'XLim', [1 1.5], 'Xtick', []);
    
    %bar( x_bar, fr, 'group'); hold on;
    %errorbar(x_err, fr, std);
    
   
end


function clusters = check_for_interneurons(clusters)
    good_ind = logical( 1:numel(clusters) );
    
    for i = 1:numel(clusters)
       warning off;
       [val ind] =  max(log(histc(diff(clusters(i).time), 0:.001:1)));
       warning on;
       if numel(clusters(i).time)>10000
           good_ind(i) = 0;
       end
    end
    sum(~good_ind)
    clusters = clusters(good_ind);
end