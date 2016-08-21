function [mu, HPC, CTX] = load_HPC_RSC_data(nLoad)

%{'spl11', 'spl11', 'spl11'}, [15 12 11], [2 1 2];
base = {'gh-rsc1', 'gh-rsc2', 'spl11'};
bId = [1 1 1 1 1 2 2 2 2];
day = [18, 22, 23, 24, 28, 22, 24, 25, 26];
ep = [3, 1, 1, 2, 3, 3, 3, 3, 3];


fprintf('\nLOADING THE RAW DATA\n');

if nargin == 0
    nLoad = numel(bId);
end

for i = 1:nLoad
    
    % LOAD THE DATA
    epoch = sprintf('sleep%d', ep(i));
    edir = sprintf('/data/%s/day%d', base{bId(i)}, day(i));
    
    [~, anat] = load_exp_tt_anatomy(edir);
    nHPC = nnz(strcmp('rCA1', anat));
    nCTX = nnz(strcmp('RSC', anat));
    
    fName = sprintf('MU_HPC_RSC_%s.mat', upper(epoch));
    fprintf('%s %d %s', base{bId(i)}, day(i), fName );
    tmp = load( fullfile(edir, fName) );
    mu(i) = tmp.mu;
    mu(i).hpc = mu(i).hpc / nHPC;
    mu(i).ctx = mu(i).ctx / nCTX;
    
    if nargout>1
        fName = sprintf('EEG_HPC_1500_%s.mat', epoch);
        fprintf(', %s', fName );
        tmp = load( fullfile(edir, fName) );
        
       
            HPC(i) = orderfields(tmp.hpc);
       
    end
    if nargout>2
        fName = sprintf('EEG_CTX_1500_%s.mat', epoch);
        fprintf(', %s', fName );
        tmp = load( fullfile(edir, fName) );
        CTX(i).ts = tmp.ctx.ts;
        CTX(i).lfp = tmp.ctx.data;
    end
    fprintf('\n');
end

fprintf('---------------DATA LOADED!---------------\n');


end