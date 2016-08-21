function chans = dset_calc_eeg_chans_to_load(dset, args)

if ~isfield(dset, 'clusters')
        error('Load clusters first');
    end
    
    % we only want to load 3 channels of EEG so lets figure out which channels to load 
    % go through the list of cluster and count how often each tetrode
    % appears, ignore tetrodes that aren't in CA1
    tetCount = zeros(1,30);
    tetLat = cell(1,30);
    for j = 1:numel(dset.clusters)
        tet = dset.clusters(j).tetrode;
        % skip tetrodes not in the specified area
        if ~strcmp(dset.clusters(j).area, args.structure)
            continue;
        end
        tetCount(tet) = tetCount(tet)+1;
        tetLat{tet} = dset.clusters(j).hemisphere;
    end

    %sort the list of tetrodes by number of cells, sort the count and lat vectors using this list
    [~, idx] = sort(tetCount, 2, 'descend');
    tetCount = tetCount(idx);
    tetLat = tetLat(idx);

    % get a list of 3 channels, 2 from 1 side 1 from the other
    chans = [0 0 0];
    chanCount = 1;
    % keep track of how many channels for each side have been grabbed
    leftCount = 0; 
    rightCount = 0;

    for j = 1:numel(tetCount)
        % if channel is on the right and we have less than 2 right channels already
        if strcmp(tetLat{j}, 'right') && rightCount<2
            chans(chanCount) = idx(j);
            rightCount = rightCount+1;
            chanCount = chanCount + 1;
        % if channel is on the left and we have less than 2 right channels already
        elseif strcmp(tetLat{j}, 'left') 
            chans(chanCount) = idx(j);
            leftCount = leftCount+1;
            chanCount = chanCount+1;
        end
        % if all channels have been picked break
        if all(chans)
            break;
        end
    end
    
    

end