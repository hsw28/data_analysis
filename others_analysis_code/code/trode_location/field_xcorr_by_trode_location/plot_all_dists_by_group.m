function f = plot_all_dists_by_group(fieldDists,anatomicalDists,xcorrDists,fieldCells,trodeGroups,pairColorMap)

fieldAreas = cmap(@(x) cellArea(x,trodeGroups), fieldCells);
fieldAreas = cmap(@(x) x.name, fieldAreas);

for n = 1:numel(pairColorMap.keys())
 ks = pairColorMap.keys();
 [rArea,cArea] = parseAreaString(ks{n});
 thisColor = pairColorMap(ks{n});
 plotOneGroup(fieldDists,anatomicalDists,xcorrDists,...
     fieldAreas,rArea,cArea,thisColor);
 hold on;
end

end

function f = plotOneGroup(fDists,aDists,xDists,fieldAreas,rowArea,colArea,c)

    fDists = pruneAndFlatten(fDists,rowArea,colArea,fieldAreas);
    aDists = pruneAndFlatten(aDists,rowArea,colArea,fieldAreas);
    xDists = pruneAndFlatten(xDists,rowArea,colArea,fieldAreas);
    
    eitherIsNaN = isnan(fDists) | isnan(aDists) | isnan(xDists);
    fDists = fDists(~eitherIsNaN);
    aDists = aDists(~eitherIsNaN);
    xDists = xDists(~eitherIsNaN);
     
    f = plot(fDists,xDists,'.','Color',c);
     
end

function m = pruneAndFlatten(a, rowArea, colArea, fieldAreas)
    keepRows = strcmp(rowArea, fieldAreas);
    keepCols  = strcmp(colArea, fieldAreas);
    keep = true * ones(size(a));
    keep(~keepRows,:) = false;
    keep(:,~keepCols)  = false;
    a = reshape(a,1,[]);
    keep = reshape(keep,1,[]);
    m = a(logical(keep));
end

function area = cellArea(clustName, trodeGroups)
area = group_of_trode(trodeGroups, clustName(6:7));
end

function [a1,a2] = parseAreaString(s)
isPipe = s == '|';
s2 = cumsum(isPipe);
a1 = s(s2 == 0);
a2 = s(s2 == 1 & (~isPipe));
end