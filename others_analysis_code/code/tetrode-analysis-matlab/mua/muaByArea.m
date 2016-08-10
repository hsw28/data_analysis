function muaArea = muaByArea(muaAll, trode_groups, area)

areas = cmap(@(x) x.name, trode_groups);

tGInd = strcmp( area, areas );

if(sum(tGInd) == 0)
    error('muaByArea:noAreaMatch',['Couldn''t find area named ', area, ...
        '. Possibilities are: ', cell2mat(areas)]);
elseif (sum(tGInd > 1))
    error('muaByArea:multipleMatches',['Found multiple areas matching name ', area]);
end

trodes = trode_groups{tGInd}.trodes;

muaArea = sdatslice(muaAll,'trodes',trodes);