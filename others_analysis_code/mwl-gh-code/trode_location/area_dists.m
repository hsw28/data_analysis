function ds = area_dists(d,m,anatomicalAxis, areaA,areaB)

    [~,~,~,dists,~,fieldCells] = full_xcorr_analysis(d,m,...
        'axis_vector',anatomicalAxis,...
        'ok_pair',[areaA,',',areaB]);
    trode_groups = m.trode_groups_fn('date',m.today,'segment_style','ml');
    for r = 1:size(dists,1);
        for c = 1:size(dists,2)
            cellR = fieldCells{r};
            cellC = fieldCells{c};
            groupR = trode_group(cellR(6:7),trode_groups);
            groupC = trode_group(cellC(6:7),trode_groups);
            if(isempty(groupR) || isempty(groupC))
                dists(r,c) = NaN;
            elseif ~(strcmp(areaA,groupR.name) && strcmp(areaB,groupC.name))
                dists(r,c) = NaN;
            end
        end
    end
    ds = abs(dists(~isnan(dists)));
    
end