sl15 = exp_load('/home/slayton/data/spl11/day15', 'epochs', {'run'}, 'data_types', {'clusters'});
c = sl15.run.cl;
%%

w = [];

for i = numel(c)
    filePath = fullfile( fileparts(fileparts(c(i).file)), sprintf('%s.tt', c(i).tt));
    idx = c(i).id;
    [~, ~, waves] = load_spike_parameters(filePath, 'idx', idx);
    waves = mean(waves,3);
    w = [w, waves(1,:)];
    x = [x, i + 1.Z/(-15:16)];

end
%%
x = [];
for i = 1:numel(c)
        x = [x, i + (-15:16)/32];
end
w(32:32:end) = nan;
%%
for i = 58
    filePath = fullfile( fileparts(fileparts(c(i).file)), sprintf('%s.tt', c(i).tt));
    idx = c(i).id;
    [~, ~, waves] = load_spike_parameters(filePath, 'idx', idx);
    wavesAll = squeeze(mean(waves,1));    
end
%%
waves = wavesAll;

[~, peakIdx] = max(waves);
idx = peakIdx < 15;

nWave = 5;
nSample = 25;

w = [];
sampPerWave = 32;
for i = 1:nWave
    r = (.15 * (3 - i) + 1) / 3000;
    ind = randsample(find(idx), nSample);
    mean_wave = mean( waves(:,ind), 2 ) * r;
    
%     filler = interp1([1 9], mean_wave([end-2, 1]), 1:9);
%     mean_wave(end-2:end+6) = filler;
%     mean_wave(end+1:end+2) = mean_wave(1);
%     mean_wave = smoothn(mean_wave,1);
     mean_wave = mean_wave - mean_wave(1) + 1;
    
    w(:,i) = interp1(1:32, mean_wave, linspace(1,32,120));
    
end

close all;
plot(w);

%%

fprintf('\n\n{\n');
for i = 1:5
    fprintf('{\t');
    for j = 1:120
        fprintf('%02.4f, ', w(j,i));
        if j==120
            fprintf('}, \n');
        elseif mod(j,12)==0
            fprintf('\n\t');
        end
    end
end
fprintf('};\n');
%%
w = w(:,1);
s = ones(size(w));
[~, iMax] = max(w);
[~, iMin] = min(w);
s(iMax) = 3;
s = smoothn(s,9, 'correct', 1);
close all;
plot(s);


%%

fprintf('{\n\t');
for i = 1:120
    fprintf('%02.4f, ', s(i));
    if mod(i,12)==0
        fprintf('\n\t');
    end
end
fprintf('}\n');