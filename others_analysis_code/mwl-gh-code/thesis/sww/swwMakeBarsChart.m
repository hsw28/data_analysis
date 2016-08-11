function rates = swwMakeBarsChart()

rowNames = {'sleep','drowsy','run','normalPause','nightPause'};
colNames = {'CA1','RSC','CTX'};

sessionRateValues  = cell(numel(rowNames),numel(colNames));

mds = swwDataSpec();
dataSpecAssertGood(mds,rowNames,colNames);

for i = 1:numel(mds)
    thisMd = mds{i};
    for aInd = 1:numel(thisMd.areas)
        for sInd = 1:numel(thisMd.sessions)
            rowInd = find(strcmp(thisMd.sessions{sInd}, rowNames));
            colInd = find(strcmp(thisMd.areas{aInd}, colNames));
            thisVal = ...
                swwBarOne(thisMd,...
                aInd, ...
                sInd,true,0);
            sessionRateValues{rowInd,colInd} = ...
                [sessionRateValues{rowInd,colInd},thisVal];
        end
    end
end

rates = sessionRateValues;

end




function dataSpecAssertGood(d,rowNames,colNames)
% Check for typos & types in field names
    a = @assert;
    for n =1:numel(d)
        di = d{n};
        a(numel(fieldnames(di)) == 5);
        a(isfield(di,'mdata'));
        a(isfield(di,'twin'));
        a(isfield(di,'areas'));
        a(isfield(di,'sessions'));
        a(isfield(di,'thresh'));
        a(iscell(di.areas));
        a(iscell(di.sessions));
        a(all( cellfun(@(x) any(strcmp(x,colNames)), di.areas) ));
        a(all( cellfun(@(x) any(strcmp(x,rowNames)), di.sessions)));
        
    end

end

