function save_new_decoding_figures(figName, fHandle, sup)

figName(1) = upper(figName(1));
if nargin==2
    saveDir = '/data/amplitude_decoding/NEW_FIGURES';
elseif nargin==3 && ~isempty(sup) && sup==1
    saveDir = '/data/amplitude_decoding/NEW_FIGURES/sup';
end

if ~exist(saveDir, 'dir');
    cmd = ['mkdir -p ', saveDir];
    unix(cmd);
end

date = datestr(now, 'yyyymmdd');

oldDir = fullfile(saveDir, 'old');
if ~exist(oldDir, 'dir')
    mkdir(oldDir);
end

if ~exist( fullfile(oldDir, date));
    mkdir( fullfile(oldDir, date));
end

cmd = ['mv ', fullfile(saveDir,[figName, '*']), ' ', fullfile(oldDir, date)];
system(cmd);

%figName = [figName,'', datestr(now, 'yyyymmdd'),'_'];

set(gcf,'InvertHardcopy', 'off');

saveFigure(fHandle, saveDir, figName, 'png', 'fig', 'svg');

end