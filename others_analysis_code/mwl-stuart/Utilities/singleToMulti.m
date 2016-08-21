function multiUnit = singleToMulti(singleUnit)
multiUnit=[];
for cell=1:length(singleUnit)
%    disp(cell)
    %for time=1:length(singleUnit(cell).times)
     %   multiUnit(length(multiUnit)+1) = singleUnit(cell).times(time);
    %end
    if size(multiUnit) == [0 0]
        multiUnit= singleUnit(cell).time;
    else
    multiUnit= [multiUnit, singleUnit(cell).time];
    end
end
multiUnit = sort(multiUnit);
