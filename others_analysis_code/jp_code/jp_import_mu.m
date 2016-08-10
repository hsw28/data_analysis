function mua = jp_import_mu(edir)
    
    if ~exist(edir,'dir')
        warning('%s directory does not exist', edir);
        mua = [];
        return;
    end
    
    muFile = fullfile(edir, 'mua.mat');
    
    if ~exist(muFile,'file')
        warning('%s file does not exist', muFile);
        mua = [];
        return;
    end
    
    fprintf('Loading MU from:%s\n', edir);
    tmp = load(muFile);
    mua = tmp.mua;
    
end