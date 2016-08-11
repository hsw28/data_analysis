function r = thetaSequenceNumbers()

r.sequenceSlope = [];
r.sequenceYIntercept = [];

c = curationData();
rats = c.ca1Sequences;

for ratInd = 1:numel(rats)
   
    cd(rats{ratInd});
    m = metadata();
    if exist('d.mat');
        load d.mat
    else
        d = loadData(m,'segment_style','ml');
        save d.mat d
    end
    
    
        
end