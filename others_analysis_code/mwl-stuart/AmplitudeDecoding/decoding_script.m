
%% Load Data
clear
ep = 'amprun';
dTypes = {'pos'};

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
matlabpool('open', 4);

%% Setup Data Sets
% clear exps
% edir{1) = exp13;
% edir{2) = exp14;
% edir{3) = exp15;
% edir{4) = exp16;
% %% Spike and Time Counters
% clear ns_tot dt_tot
% ns_tot = [];
% dt_tot = [];


%% Wave Widths
% clearvars -except exp13 exp14 exp15 exp16 exps ns_tot dt_tot
% disp('WAVE WIDTHS------------------');
% for exp_num=1:numel(exps)
%     exp = edir{exp_num);
%     disp(['Decoding data from: ' exp.edir]);
%     decoding_compare_wave_widths;
%     ns_tot = [ns_tot input.n_spike];
%     dt_tot = [dt_tot output.elapsed_time];
% end

%% Amp & Pos Kernel Widths
% 
% disp('Kernel Widthds----------');
% for i=3%5:numel(edir)  %<----- Fix Index start value
%    exp_in = exp_load(edir{i}, 'epochs', ep, 'data_types', dTypes);
%    ep_in = 'amprun';
%    disp(['Decoding data from: ' exp_in.edir]);
%    decoding_compare_kw;
% end

%% Position Kernel Widths

% disp('Position Kernel Widthds----------');
% for i=1:4  %<----- Fix Index start value
%    exp_in = exp_load(edir{1}, 'epochs', ep, 'data_types', dTypes);
%    ep_in = 'amprun';
%    disp(['Decoding data from: ' exp_in.edir]);
%    decoding_compare_kw_pos;
% end

%% Voltage Tholds
% disp('VOLTAGE THRESHOLDS----------');
% for i=1:numel(exps)
%     exp_in = exp_load(edir{1}, 'epochs', ep, 'data_types', dTypes);
%     ep_in = 'amprun';
%     disp(['Decoding data from: ' exp_in.edir]);
%     decoding_compare_amp_thresholds;
% end


%% Cell ID (Clustered) vs Amplitude Decoding
% disp('CELL ID VS AMP------------');
% dTypes = {'clusters', 'pos'};
% for i=1:numel(edir)
%     exp_in = exp_load(edir{i}, 'epochs', ep, 'data_types', dTypes);
%     ep_in = 'amprun';
%     disp(['Decodin g data from: ' edir]);
%     decoding_compare_cl_vs_non_cl;
% end
%% Amplitude Scaling Comparison
% disp('AMPLITUDE SCALING--------');
% for i=11:numel(exps)
%     exp_in = exp_load(edir{1}, 'epochs', ep, 'data_types', dTypes);
%     ep_in = 'amprun';
%     disp(['Decoding data from: ' exp_in.edir]);
%     decoding_compare_amplitude_scaling;
% end
%% Tetrode vs Electrode
disp('NUM CHANNEL -------------');
for i=1:numel(edir)

    exp_in = exp_load(edir{i}, 'epochs', ep, 'data_types', dTypes);
    ep_in = 'amprun';
    disp(['Decoding data from: ' exp_in.edir]);
    decoding_compare_num_channels;
    
end
matlabpool close
%% Significance Testing
% disp('Significance Testing Decoding ---------');
% for i=1:numel(edir)
%     exp_in = exp_load(edir{i}, 'epochs', ep, 'data_types', dTypes);
%     ep_in = ep;
%     disp(['Decoding data from: ' exp_in.edir]);
%     decoding_sig_test;
% end
%% Close the matlab pool
matlabpool close;