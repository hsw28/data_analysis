function [amps, n_spikes] = select_amps_by_feature(amps, varargin)

% sub selects spikes from the amps cell array that fall within a feature
% range

args.feature = 'none specified';
args.range = [-Inf Inf];
args.col_num = -1;

args = parseArgsLite(varargin, args);

if strcmp(args.feature, 'col') && args.col_num==-1
    error('Must specify col_num');
end

n_spikes = 0;
for i=1:numel(amps)
    a = amps{i};
    switch args.feature
        case 'ts'
            in = find(args.range(1)<=a(:,5),1, 'first');
            if ~isempty(in)
                ind(1) = in;
                in = find(args.range(2)>=a(:,5),1,'last');
                if ~isempty(in)
                    ind(2) = in;
                else
                    ind(2) = ind(1);
                end
                ind = ind(1):ind(2)-1; 
            else
                ind = [];
            end
        case 'velocity'
            ind = abs(a(:,7))>= args.range(1) & abs(a(:,7))<args.range(2);
        case 'col'
            ind = abs(a(:,args.col_num))>= args.range(1) & abs(a(:,args.col_num))<args.range(2);
        case 'amplitude'
            maxes = max(a(:,1:4),[],2);
            ind = maxes>=args.range(1) & maxes<(args.range(2));
        otherwise
            error('not defined');
    end
    amps{i} = a(ind,:);
    n_spikes = n_spikes + sum(ind~=0);
end





