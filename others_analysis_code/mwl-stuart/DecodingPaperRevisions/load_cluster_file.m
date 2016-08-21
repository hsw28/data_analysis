function [id, nClust] = load_cluster_file(clFile)

d = dir(clFile);
if exist(clFile, 'file') && d.bytes>0
    
        in = dlmread(clFile, '\n');
        

        nClust = in(1);
        id = in(2:end);
    
else
    
    nClust = 0;
    id = [];
    
end


end