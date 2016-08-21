%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Comment 1 by fabian - Stats on the reduction of the spike numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

% setup the strings
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
dTypes = {'pos'};
ep = 'amprun';

%% load data compute values
nSpikes = zeros(12,3);
for day = 1:12
    
    clearvars -except edir dTypes ep day nSpikes
    
    exp_in = exp_load(edir{day}, 'epochs', ep, 'data_types', dTypes);
    input = setup_decoding_inputs(exp_in, ep);

    input.data{1} = select_amps_by_feature(input.raw_amps,'feature', 'col', 'col_num', 8, 'range', [12 40]);
    input.data{1} = select_amps_by_feature(input.data{1}, 'feature', 'amplitude', 'range', [125 Inf]);
    input = rmfield(input,'raw_amps');

    cols = [ 1 1 1 1; 1 1 0 0;  1 0 0 0];
    %%

    for i = 1:3

        dataIn = input.data{1};
        for j = 1:numel(dataIn)
            tmp =  dataIn{j}(:,1:4);
            tmp(:,~cols(i,:)) = 0;
            dataIn{j}(:,1:4) = tmp;
        end
        dataIn = select_amps_by_feature(dataIn, 'feature',  'amplitude', 'range', [125 Inf]);
        nSpikes(day, i) = sum( cellfun( @(x) size(x,1), dataIn) );    
    end
end
%% Compute Results
per(:,1) = nSpikes(:,2)./nSpikes(:,1);
per(:,2) = nSpikes(:,3)./nSpikes(:,1);

mean(per)
std(per)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Comment 2 by fabian - Stats on the tetrodes vs stereo vs electrodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
d = {};

% list the data sets for analysis
d{end+1} ='Amp.Decoding.Channel.Number.Multi.MUAesm.day01.mat';
d{end+1} ='Amp.Decoding.Channel.Number.Multi.MUAesm.day02.mat';
d{end+1} ='Amp.Decoding.Channel.Number.Multi.MUAfk11.day08.mat';
d{end+1} ='Amp.Decoding.Channel.Number.Multi.MUArat1.day01.mat';
d{end+1} ='Amp.Decoding.Channel.Number.Multi.MUArat1.day02.mat';
d{end+1} ='Amp.Decoding.Channel.Number.Multi.MUArat2.day01.mat';
d{end+1} ='Amp.Decoding.Channel.Number.Multi.MUArat2.day02.mat';
d{end+1} ='Amp.Decoding.Channel.Number.Multi.MUAsaturn.day02.mat';
d{end+1} ='Amp.Decoding.Channel.Number.Multi.MUAspl11.day13.mat';
d{end+1} ='Amp.Decoding.Channel.Number.Multi.MUAspl11.day14.mat';
d{end+1} ='Amp.Decoding.Channel.Number.Multi.MUAspl11.day15.mat';
d{end+1} ='Amp.Decoding.Channel.Number.Multi.MUAspl11.day16.mat';
%% load each data set and grab the important stats

teA = 1;
stA = 5;
stM = 6;
elA = 7;
elM = 8;

teSt = [];
stSt = [];
elSt = [];
fprintf('Loading:');
for i = 1:numel(d)
    fprintf(' %d', i);
    load(fullfile('/data/amplitude_decoding', d{i}));
    
    teSt(i,1) = output.stats.me(teA);
    
    stSt(i,1) = output.stats.me(stA);
    stSt(i,2) = output.stats.me(stM);
    
    elSt(i,1) = output.stats.me(elA);
    elSt(i,2) = output.stats.me(elM);
    
    [stKs(i) stP(i)] = kstest2(output.stats.errors{stA}, output.stats.errors{stM}, .05, 'larger');
    [elKs(i) elP(i)] = kstest2(output.stats.errors{elA}, output.stats.errors{elM}, .05, 'larger');
    
    clear input output;
end
%%
fprintf('\n\n\n\n\n\n\n\n');

disp('stereo vs 1 chan:');
disp(signrank(stSt(:,1), elSt(:,1)));

disp('tet vs stero')
disp(signrank(stSt(:,1), teSt(:,1)));

el2St = elSt(:,1) - stSt(:,1);
st2Te = stSt(:,1) - teSt(:,1);

perImpEl2St = el2St ./ elSt(:,1);
perImpSt2Te = st2Te ./ stSt(:,1);

disp('el 2 st');
disp('min, mean, max');
disp([min(perImpEl2St), mean(perImpEl2St), max(perImpEl2St)])
disp('st 2 te');
disp('min, mean, max');
disp([min(perImpSt2Te), mean(perImpSt2Te), max(perImpSt2Te)])

[h p] =  kstest2(perImpSt2Te, perImpEl2St, .05, 'larger');
disp('signrank  ranksum  kstest2')
[ signrank(perImpSt2Te, perImpEl2St) ranksum(perImpSt2Te, perImpEl2St), p]










