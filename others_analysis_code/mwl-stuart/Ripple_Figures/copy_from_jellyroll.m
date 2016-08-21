
function copy_from_jellyroll(day)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  JELLY ROLL - greghale@10.121.43.47
%  ELDRIDGE   - rsx@10.121.43.163
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==32673
    day = 21;
end

% user = 'rsx';
% ip = '10.121.43.163';
% outBaseDir = sprintf('~/gilbertz/01%02d13', day);

user = 'greghale';
ip = '10.121.43.47';
outBaseDir = sprintf('~/Data/caillou/11%02d12', day);

inBaseDir = sprintf('/data/gh-rsc1/day%02d', day);

if ~exist(inBaseDir,'dir')
    mkdir(inBaseDir);
end


cmd = sprintf('scp -r %s@%s:"', user, ip);
for i = 1:30;
    
    localdir = fullfile(inBaseDir, sprintf('t%02d', i));
    if exist( localdir, 'dir')
        continue;
    end
    
    localdir = fullfile(inBaseDir, sprintf('%02d%d', i, day));
    if exist( localdir , 'dir')
        continue;
    end
    
    
    d = sprintf('%02d%d', i, day);
    cmd = [cmd, fullfile(outBaseDir, d), ' '];
end

cmd = [cmd, fullfile(outBaseDir,'epoch.init')];
cmd = [cmd,'" ' inBaseDir];
fprintf('Executing command:\n%s\n', cmd);
system(cmd);

end
