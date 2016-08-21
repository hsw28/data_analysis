function dset = dset_order_eeg_channels(dset, args)

    %old checks - but remove channels that aren't in the specified area
    areaIdx = strcmp(args.structure, {dset.eeg.area});
    dset.eeg = dset.eeg(areaIdx);

    %figure out which channels are base, ipsi, and cont
    %filter out all channels but 3, 2 ipsi chans and 1 cont chan
    leftIdx = find(strcmp({dset.eeg.hemisphere}, 'left'));
    rightIdx = find(strcmp({dset.eeg.hemisphere}, 'right'));

    if isempty(leftIdx) || isempty(rightIdx)
        if numel(leftIdx>0)
            baseChan = leftIdx(1);
        else
            baseChan = rightIdx(1);
        end
        dset.eeg = dset.eeg(baseChan);
        dset.channels.base = baseChan;
        dset.channels.ipsiIdx = [];
        dset.channels.contIdx = [];    
    else
        if numel(leftIdx)>1
            baseChan = leftIdx(1);
            ipsiChan = leftIdx(2);
            contChan = rightIdx(1);
        elseif numel(rightIdx) >1
            baseChan = rightIdx(1);
            ipsiChan = rightIdx(2);
            contChan = leftIdx(1);
        else
            error('Both leftIdx and rightIdx have fewer than 2 values!');
        end


    dset.eeg = dset.eeg([baseChan, ipsiChan, contChan]);

    dset.channels.base = 1;
    dset.channels.ipsi = 2;
    dset.channels.cont = 3;
    
    end
end