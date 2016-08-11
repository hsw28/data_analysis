function mapAC = mapCompose(mapBC, mapAB)
% mapCompose :: map b c -> map a b -> map a c

mapAC = containers.Map();

abKeys = mapAB.keys;
for n = 1:size(mapAB)
    if(any( strcmp( mapAB(abKeys{n}), mapBC.keys ) ) )
        mapAC( abKeys{n} ) = mapBC( mapAB(abKeys{n}) );
    end
end