
%% Clear the workspace
clear; clc; close all;
%%
% Define the datasets
ep = 'amprun';
dTypes = {'pos'};

edir = {};

edir{end+1} = '/data/spl11/day13';
edir{end+1} = '/data/spl11/day14';
edir{end+1} = '/data/spl11/day15';
edir{end+1} = '/data/spl11/day16';
edir{end+1} = '/data/jun/rat1/day01';
edir{end+1} = '/data/jun/rat1/day02';
edir{end+1} = '/data/jun/rat2/day01';
edir{end+1} = '/data/jun/rat2/day02';
edir{end+1} = '/data/greg/esm/day01';
edir{end+1}= '/data/greg/esm/day02';
edir{end+1}= '/data/greg/saturn/day02';
edir{end+1}= '/data/fabian/fk11/day08';

nDset = numel(edir);
[P1, P4, E1, E4, I1, I4] = deal( repmat({}, nDset,1) );

for i = 1:nDset
   
    fprintf('--------------- %s ---------------\n', upper(edir{i}));
    [P4{i}, E4{i}, I4{i}] = decode_feature_vs_cluster(edir{i}, 4);
    [P1{i}, E1{i}, I1{i}] = decode_feature_vs_cluster(edir{i}, 1);

    fprintf('\n');
    
end

%% Save the decoding results

save( '/data/amplitude_decoding/REVISIONS/decode_all_results.mat', 'P1', 'P4', 'E1', 'E4', 'I1', 'I4');

% The below functionality was moved to utils/save_new_decoding_figures.m
% %% Write the results to a table
% % load /data/amplitude_decoding/REVISIONS/decode_all_results.mat
% 
% %% Table 1 - Data set summary
% E = E4;
% IN = I4;
% N = numel(E4);
% [nS4, nS1, nT4, nT1, nU4, nU1] = deal( nan(N,1) );
% 
% for i = 1:N
%     
%     nS4(i) = I4{i}.nSpike(1); 
%     nT4(i) = sum( ~cellfun(@isempty, I4{i}.data{1} ) );
%     nU4(i) = sum( ~cellfun(@isempty, I4{i}.data{2} ) );
%     
%     nS1(i) = I1{i}.nSpike(1);
%     nT1(i) = sum( ~cellfun(@isempty, I1{i}.data{1} ) );
%     NU1(i) = sum( ~cellfun(@isempty, I1{i}.data{2} ) );
%     
% end
% 
% rName = {'SL13', 'SL14', 'SL15', 'SL16', 'R1D1', 'R1D2', 'R2D1', 'R2D2', 'ESM11', 'ESM2', 'SAT2', 'FK11'};
% cName = {'4Ch - N. TT', '4Ch - N. Spikes', '4Ch - N. Unit', '1Ch - N. TT', '1Ch - N. Spikes', '1Ch - N. Unit'};
% 
% table1Data = [nT4, nS4, nU4, nT1, nS1, nU1];
% writeTable(cName, rName, table1Data,  '/data/amplitude_decoding/REVISIONS/table1.csv');
% 
% %% Table 2 - Summary of Decoding Accuracy
% [meF4, meI4, meF1, meI1] = deal( nan(N,1) );
% 
% for i = 1:N
%     meF4(i) = E4{i}(1).summary_error;
%     meI4(i) = E4{i}(2).summary_error;
%     
%     meF1(i) = E1{i}(1).summary_error;
%     meI1(i) = E1{i}(2).summary_error;
% end
% 
% 
% mError = [meF4, meI4, meF1, meI1];
% cName = {'4Ch - Feature', '4Ch - Identity', '1Ch - Feature', '1Ch - Identity'};
% writeTable(cName, rName, mError, '/data/amplitude_decoding/REVISIONS/table2.csv');
% 
% figure;
% ax = [];
% ax(1) = subplot(121);
% ax(2) = subplot(122);
% set(ax,'NextPlot', 'add', 'FontSize', 14);
% 
% line(1:2, mError(:, 1:2), 'Parent', ax(1), 'Color', [.7 .7 .7] );
% boxplot(ax(1), mError(:,1:2));
% 
% 
% line(1:2, mError(:, 3:4), 'Parent', ax(2), 'Color', [.7 .7 .7] );
% boxplot(ax(2), mError(:,3:4));
% 
% 
% set(ax,'YLim', [0 1]);
% ylabel(ax(1), 'Median Error(m');
% ylabel(ax(2), 'Median Error(m');
% 
% title(ax(1), '4 Channels');
% title(ax(2), '1 Channel');
% 
% set(ax,'XTick', [1 2], 'XTickLabel', {'Feature', 'Identity'});
% 
% [~, pT4] = ttest2(mError(:,1), mError(:,2), .05, 'left');
% pS4 = signrank(mError(:,1), mError(:,2), .05, 'tail', 'left');
% text(.65, .97, sprintf('p = %3.4e -  tTest', pT4), 'Parent', ax(1), 'HorizontalAlignment', 'left');
% text(.65, .92, sprintf('p = %3.4e -  signRank', pS4), 'Parent', ax(1), 'HorizontalAlignment', 'left');
% 
% 
% [~, pT1] = ttest2(mError(:,3), mError(:,4), .05, 'left');
% pS1 = signrank(mError(:,3), mError(:,4), .05, 'tail', 'left');
% text(.65, .97, sprintf('p = %3.4e -  tTest', pT1), 'Parent', ax(2), 'HorizontalAlignment', 'left');
% text(.65, .92, sprintf('p = %3.4e -  signRank', pS1), 'Parent', ax(2), 'HorizontalAlignment', 'left');
% 
% 
% plot2svg('/data/amplitude_decoding/REVISIONS/feature_vs_identity.svg', gcf)
