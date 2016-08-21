function dset = dset_load_all(animal, day, epoch, varargin)

if strfind(animal, 'spl')
   
    if ~ischar(day)
        day = sprintf('day%d', day);
    end
    
    edir = fullfile('/data/', animal, day);
    
    dset = dset_exp_load(edir, epoch);
    
    return;
    
elseif strfind(animal, 'gh-rsc')
    edir = fullfile('/data/', animal, day);
    dset = dset_exp_load(edir, epoch);
    
    return;
elseif strfind(animal, 'sg-rat2')
    edir = fullfile('/data/', animal, day);
    dset = dset_exp_load(edir, epoch);
    
    return;
end

args = dset_get_standard_args();
args = args.load_all; 

args.clusters = 1;
args.eeg = 1;
args.mu = 1;
args = parseArgs(varargin, args);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             LOAD CLUSTERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
if args.clusters == 1
    %Load the raw clusters, position, and eeg data from the .mat files
    fprintf('Loading CLUSTERS for %s %d-%d\n\t', animal, day, epoch);
    dset.clusters = dset_load_clusters(animal, day, epoch);

    fprintf('Loading POSITION for %s %d-%d\n', animal, day, epoch);
    if mod(epoch,2)==0
        dset.position = dset_load_position(animal, day, epoch);
    end

    dset.description.animal = animal;
    dset.description.day = day;
    dset.description.epoch = epoch;
    dset.description.args = args;

    dset.epochTime = dset_load_epoch_times(animal, day, epoch);

    chans = dset_calc_eeg_chans_to_load(dset, args);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             LOAD EEG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if args.eeg == 1
    fprintf('Loading EEG for %s %d-%d\n', animal, day, epoch);
    chans(end+1) = dset_get_ref_channel(animal, day, epoch);
    [dset.eeg] = dset_load_eeg(animal, day, epoch, chans);

    dset = dset_order_eeg_channels(dset,args);
    % %old checks - but remove channels that aren't in the specified area
    % areaIdx = strcmp(args.structure, {dset.eeg.area});
    % dset.eeg = dset.eeg(areaIdx);
    % 
    % %figure out which channels are base, ipsi, and cont
    % %filter out all channels but 3, 2 ipsi chans and 1 cont chan
    % leftIdx = find(strcmp({dset.eeg.hemisphere}, 'left'));
    % rightIdx = find(strcmp({dset.eeg.hemisphere}, 'right'));
    % 
    % if isempty(leftIdx) || isempty(rightIdx)
    %     if numel(leftIdx>0)
    %         baseChan = leftIdx(1);
    %     else
    %         baseChan = rightIdx(1);
    %     end
    %     dset.eeg = dset.eeg(baseChan);
    %     dset.channels.base = baseChan;
    %     dset.channels.ipsiIdx = [];
    %     dset.channels.contIdx = [];    
    % else
    %     if numel(leftIdx)>1
    %         baseChan = leftIdx(1);
    %         ipsiChan = leftIdx(2);
    %         contChan = rightIdx(1);
    %     elseif numel(rightIdx) >1
    %         baseChan = rightIdx(1);
    %         ipsiChan = rightIdx(2);
    %         contChan = leftIdx(1);
    %     else
    %         error('Both leftIdx and rightIdx have fewer than 2 values!');
    %     end
    % 
    % 
    %     dset.eeg = dset.eeg([baseChan, ipsiChan, contChan]);
    % 
    %     dset.channels.base = 1;
    %     dset.channels.ipsi = 2;
    %     dset.channels.cont = 3;

    %     fprintf('\tfiltering EEG for ripples\n');
    %     dset = dset_filter_eeg_ripple_band(dset);
    % end
    % calcuate ripple events
    %     for j = 1:3
    %         [dset.ripples(j).window dset.ripples(j).maxTimes] = find_rip_burst(dset.eeg(j).data, dset.eeg(j).fs, dset.eeg(j).starttime);
    %     end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             LOAD MULTI-UNIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if args.mu == 1
    lIdx = strcmp({dset.clusters.hemisphere}, 'left') & strcmp({dset.clusters.area}, 'CA1');
    rIdx = strcmp({dset.clusters.hemisphere}, 'right') & strcmp({dset.clusters.area}, 'CA1');
    tetId = cell2mat({dset.clusters.tetrode});

    lTet = unique( tetId( lIdx));
    rTet = unique( tetId( rIdx));

    fprintf('Loading mua for %s %d-%d\n', animal, day, epoch);
    
    dset.mu = dset_load_mu(animal, day, epoch, 'timewin', dset.epochTime,'left', lTet, 'right', rTet);
    
    if isfield(dset, 'position')
        dset.mu.bursts = dset_find_mua_bursts(dset.mu, 'pos_struct', dset.position);
    else
        dset.mu.bursts = dset_find_mua_bursts(dset.mu, 'filter_on_velocity', 0);
    end

    % [dset.amp.amps dset.amp.colnames] = dset_load_spike_wave_parameters(animal, day, epoch, 1:30);
    % dset.amp.info = dset_load_tetrode_info(animal, day, epoch);
    %dset.amp.distmat = dset_load_distance_matrix(animal, day, epoch);
    dset.mu = orderfields(dset.mu);
end

end
