
clear; 
basedir = '/data/spl11/day13';
ep = 'amprun';

%%
NEW = load_dataset_waveforms(basedir, ep);
%%
OLD = setup_decoding_inputs( exp_load(basedir, 'epochs', ep, 'data_types', {'pos'}), ep);

%%

MIN_VEL = .15;
MIN_WIDTH = 12;
MIN_AMP = 125;

nOld = [];
nNew = [];
for i = 1%:numel(NEW)

    a = NEW{i};
    b = OLD.raw_amps{i};

    if isempty(a)
        nNew(i) = 0;
    else

        runIdx = abs(a(:,7)) >= MIN_VEL;
        ampIdx = max(a(:,1:4),[],2) >= MIN_AMP;
        wideIdx = true .* a(:,8);% >= MIN_WIDTH;

        newIdx = runIdx & ampIdx & wideIdx;
        a = a(newIdx,:);
        nNew(i) = size(a,1);
    end
    if isempty(b)
        nOld(i) = 0;
    else

        runIdx = abs(b(:,7)) >= MIN_VEL;
        ampIdx = max(b(:,1:4),[],2) >= MIN_AMP;
        wideIdx = true .* b(:,8);% >= MIN_WIDTH;

        oldIdx = runIdx & ampIdx & wideIdx;
        b = b(oldIdx,:);
        nOld(i) = size(b,1);
    end
   
    
%     [~, aIdx, bIdx] = intersect( a(:,5), b(:,5));
    
end
[nNew', nOld', nNew'-nOld']

%%
close all;
figure;
axes('NextPlot', 'add');
plot(a(:, 5), a(:,6), 'r+', 'markersize', 20);
plot(b(:, 5), b(:,6), 'b.');

