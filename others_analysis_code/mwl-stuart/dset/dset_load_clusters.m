function clusters = dset_load_clusters(animal, day, epoch, varargin)
% DSET_LOAD_CLUSTERS - loads the single units and placefields from disk

args = dset_get_standard_args();
args = args.clusters;
args = parseArgs(varargin, args);

filepath = dset_get_spike_file_path(animal, day);
metapath = dset_get_cellinfo_file_path(animal);
fieldspath = dset_get_linfields_file_path(animal);

%disp(['Loading cells from file:', filepath]);

data = load(filepath);
data = data.spikes{day}{epoch};

meta = load(metapath);
meta = meta.cellinfo{day}{epoch};


if exist(fieldspath, 'file');
    fields = load(fieldspath);  
    if size(fields.linfields,1) >= day && size(fields.linfields,2) >= epoch
        fields = fields.linfields{day}{epoch};     
    else
        fields = [];
    end
else
    fields = [];

end


clusters.st = [];
nCluster = 0;
for electrode = 1:numel(data);
    
    tet = data{electrode};
    
    for cluster = 1:numel(tet)
        clust = tet{cluster};

        if isempty(clust) || isempty(clust.data)
            continue
        end
        
        nCluster = nCluster + 1;
        
        clusters(nCluster).st  = clust.data(:,1); %#ok<*AGROW>
        clusters(nCluster).day = day;
        clusters(nCluster).epoch = epoch;
        clusters(nCluster).tetrode = electrode;
        clusters(nCluster).clustId = cluster;

        if isfield(meta{electrode}{cluster}, 'area')
            clusters(nCluster).area = meta{electrode}{cluster}.area;
        else
            clusters(nCluster).area = 'unknown';
        end
        
        if isfield(meta{electrode}{cluster}, 'hemisphere')
            clusters(nCluster).hemisphere = meta{electrode}{cluster}.hemisphere;
        else
            clusters(nCluster).hemisphere = 'unknown';
        end
        
        if ~isempty(fields)
            for traj = 1:4
                tempPf  = fields{electrode}{cluster}{traj}(:,args.frank_lab_pf_idx);
                tempPf(isnan(tempPf)) = 0; %remove NANs
                tempPf = tempPf + args.base_firing_rate; % add a base firing rate for reconstruction purposes

                clusters(nCluster).traj_tc{traj} = tempPf;
            end
        end
    end
end

if args.load_place_field == 1
    if mod(epoch,2)==1 && args.sleep_load_run_fields == 1
        disp(['Current epoch is sleep, loading tuning curves from run epoch:', num2str(args.default_run_epoch)]);
        clTemp = dset_load_clusters(animal, day, args.default_run_epoch);
        clusters = dset_copy_cluster_pf(clTemp, clusters);
        
    else

        disp('Calculating place fields');
        pos = dset_load_position(animal, day, epoch);
        for i = 1:numel(clusters)
              [clusters(i).pf clusters(i).pf_edges] =...
                  dset_calc_tc(clusters(i).st, pos, mode(diff(pos.ts)));
        end
    end
end

end