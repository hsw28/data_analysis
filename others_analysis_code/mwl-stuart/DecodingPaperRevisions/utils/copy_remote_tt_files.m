function copy_remote_tt_files(host, user)
%%

if nargin < 2 || nargin > 1000
    user = 'slayton';
end

if nargin <1 || nargin > 1000
    host = '10.121.43.56';
end

edir{1} = '/data/spl11/day13';
edir{2} = '/data/spl11/day14';
edir{3} = '/data/spl11/day15';
edir{4} = '/data/spl11/day16';
edir{5} = '/data/jun/rat1/day01';
edir{6} = '/data/jun/rat1/day02';
edir{7} = '/data/jun/rat2/day01';
edir{8} = '/data/jun/rat2/day02';
edir{9} = '/data/greg/esm/day01';
edir{10}= '/data/greg/esm/day02';
edir{11}= '/data/greg/saturn/day02';
edir{12}= '/data/fabian/fk11/day08';

nExp = numel(edir);
for iExp = [2 4 5 6 7 8 9 10 11]%:nExp
   d = edir{iExp};
   fprintf('Copying all .tt files from: %s\n', d);
    
    if ~exist(d,'dir')
        cmd = sprintf('mkdir -p %s', d);
        fprintf('Creating directory: %s\n', d);
        system( cmd );
    end
    
    for i = 1:30
        tt = sprintf('t%02d', i);
        
        ttDir = sprintf('%s/%s', d, tt);
        
        if ~exist(ttDir,'dir')
            mkdir(ttDir);
        end
        
        cmd = sprintf('scp %s@%s:%s/%s.tt %s', user, host, ttDir, tt, ttDir);
        [s,w] = unix(cmd);
        fprintf('%s\n', cmd);
        
        if numel(dir(ttDir)) == 2
            rmdir(ttDir);
        end
        
    end
%     
%         ttDir = sprintf( '%s/
%     cmd = sprintf('scp -r %s@%s:%s/ %s', user, host, d, d);
%     fprintf('Executing cmd:%s\n', cmd);
%     [s, w] = unix(cmd);
    
    
    
end

end