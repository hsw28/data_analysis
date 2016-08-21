function recon = dset_reconstruct(clusters, varargin)
% DSET_RECONSTRUCT - computes a bayesian position reconstruction using single units

% get arg set, and parse user specified args
standardArgs = dset_get_standard_args;
args = standardArgs.reconstruct;
args = parseArgsLite(varargin,args);


%fprintf('Reconstructing with: %s\n', args.trajectory_type);



%setup logical indexing to remove unwanted clusters
clIdx = true(size(clusters));


% remove clusters that don't conform to the user specified area
if ~strcmp(args.area, 'all')
    clIdx = clIdx & strcmp({clusters.area}, args.area);
end


% remove clusters that don't conform to the user specified hemisphere
if ~strcmp(args.hemisphere, 'all')
    clIdx = clIdx & strcmp({clusters.hemisphere}, args.hemisphere);
end


clusters = clusters(clIdx);


% if we are using the franklab style TC, each traj is seperated into a
% different bout
if strcmp(args.trajectory_type, 'individual')
%     disp('Reconstucting DSET with independent trajectories');
    %setup matrix for the place fields
    pfEdges = clusters(1).pf_edges;
    recon.pbin_edges = clusters(1).pf_edges;

    for traj = 1:size(clusters(1).pf_edges)
        
        clear pfIdx;
        
        if traj==1
            pfIdx = [pfEdges(1,1):pfEdges(1,2), pfEdges(2,1):pfEdges(2,2)];
        elseif traj==2
            pfIdx = [pfEdges(1,1):pfEdges(1,2), pfEdges(3,1):pfEdges(3,2)];
        elseif traj==3
            pfIdx = [fliplr(pfEdges(2,1) : pfEdges(2,2)), pfEdges(3,1):pfEdges(3,2) ] ;         
        else
            warning('Invalid trajectory skipping it');
            continue;
        end

        %create the placefield matrix and trim to the places we care about
        pf = cell2mat({clusters.pf});
        pf = pf(pfIdx,:);
        
        %Check to see if we should shuffle the tuning curves
        if args.shuffle_tuning_curves ~= 0
            
            if args.shuffle_tuning_curves == 1 % col swap shuffle
                colIdx = randsample( numel(clusters), numel(clusters) );
                pf = pf(:, colIdfx);
            
            elseif args.shuffle_tuning_curves == 2 % col shift shuffle
                pf = circshift_columns(pf);
                %for i = 1:numel(clusters)
                %   pf(:,i) = circshift( pf(:,i), randi( size(pf,1) ) );
                %end
            end
            
            
        end
        [recon.pdf{traj} tbins spike_counts] = reconstruct( args.time_win(1), args.time_win(2), ...
                pf, clusters, 't_var', 'st', 'tau', args.tau);
        recon.pbins{traj} = 1:numel(pfIdx);
        recon.pfIdx{traj} = pfIdx;
    end
      
% %combine the trajectory specific curves into a single curve, forces a
% %selection between 1 of the 4 trajectories
% elseif strcmp(args.trajectory_type, 'combined')
%     pf = [];
%     
%     for traj = 1:numel(clusters(1).traj_tc)
%         pfTemp = zeros(numel(clusters(1).traj_tc{traj}), numel(clusters));
%        
%         for cell = 1:numel(clusters)
%             pfTemp(:,cell) = clusters(cell).traj_tc{traj};
%         end
%         pf = [pf; pfTemp];
%     end
%     [recon.pdf tbins spike_counts] = reconstruct( args.time_win(1), args.time_win(2), ...
%                 pf, clusters, 't_var', 'st', 'tau', args.tau);
%     recon.pbins = 1:size(pf,1);


% Same as all but for a single trajectory
elseif strcmp(args.trajectory_type, 'single')
    pf = zeros(numel(clusters(1).traj_tc{args.trajectory_number}), numel(clusters));
    for cell = 1:numel(clusters)
        pf(:,cell) = clusters(cell).traj_tc{args.trajectory_number};
    end
    
    
    [recon.pdf tbins spike_counts] = reconstruct( args.time_win(1), args.time_win(2), ...
                pf, clusters, 't_var', 'st', 'tau', args.tau);
        recon.pbins = 1:size(pf,1); 
    
        
% use simply calculated T.C.
elseif strcmp(args.trajectory_type, 'simple')
%    disp('Reconstucting DSET using a single trajectory');

    if ~isfield(clusters(1), 'pf')
       for i = 1:numel(clusters)
           clusters(i).pf = (clusters(i).tc1 + clusters(i).tc2)';
       end
    end
    pf = cell2mat({clusters.pf});

    idx = false(size(pf,1),1);

    if isempty(args.spatial_bins)
        %if no spatial bins are specified use all bins
        idx =  true(size(pf,1),1);

    elseif isvector(args.spatial_bins) && numel(args.spatial_bins) == 2
        %if a first and last index are provided
        idx(args.spatial_bins(1):args.spatial_bins(2)) = 1;  

    elseif all(islogical(args.spatial_bins)) && isvector(args.spatial_bins) && numel(args.spatial_bins) == size(pf,1)
       %if logical indecies are provided use them
        idx(args.spatial_bins) = 1;
    else

        error('Invalid spatial bins specified. Provide either a 1x2 vector [startdIdx, endIdx] or 1xN vector of logical indecies');
    end

    pf = pf(idx,:);

    [recon.pdf tbins spike_counts] = reconstruct( args.time_win(1), args.time_win(2), ...
                pf, clusters, 't_var', 'st', 'tau', args.tau);

    
            
    dp = 1;

    if isempty(args.pbins)
        pbins = 0:dp:numel(clusters(1).pf) * dp;
    else
        pbins = args.pbins;
    end
    
    % trim down the position bins to be the same bins as those used for the
    % reconstruction
    pbins = pbins(idx);
    
    recon.pbins = pbins;

    
    
else
    error('Invalid trajectory type specified, valid types are [simple/individual/combined]');
end




% 
% if args.smooth
%     disp('Smoothing, this make take some time');
%     pdf = smooth_estimate(pdf);
% end

recon.trajectory_type = args.trajectory_type;

recon.tbins = mean(tbins,2);
recon.spike_counts = spike_counts;
recon.clIdx = clIdx;

end