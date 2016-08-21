function [tc ind] = get_exp_tuning_curves(exp, epoch, varargin)
    
    args.structure = {};
    args.directional =1;
    args.shuffle = 0;
    args = parseArgsLite(varargin, args);
    
    clusters = exp.(epoch).cl;
    tc = nan(length(clusters(1).tc1), length(clusters),2);
   
    for i=1:length(clusters)
        tc(:,i,1) = clusters(i).tc1(:);
        tc(:,i,2) = clusters(i).tc2(:);
    end
    
    if isempty(args.structure) || strcmp(args.structure, 'all')
        ind = logical(1:numel(clusters));
        
    elseif ~isempty(args.structure)
        loc = {clusters.loc};
        ind = ismember(loc, args.structure);    
    end
    
    if args.shuffle == 1
        ind = randsample(numel(ind), sum(ind), 1);
    end
    
    tc = tc(:,ind,:);
    if ~args.directional
        tc = sum(tc,3);
    end
end