
%% Load DATA
input = setup_decoding!, _inputs(exp_in, ep_in);

[directory date] = fileparts(input.exp.edir);
[directory animal] = fileparts(directory);

saveData = 1;

%%


input.data{1} = select_amps_by_feature(input.raw_amps,'feature', 'col', 'col_num', 8, 'range', [12 40]);
input.data{1} = select_amps_by_feature(input.data{1}, 'feature', 'amplitude', 'range', input.param.amp_thold);

h4 = hadamard(4);
d_raw = input.data{1};
for i=1:numel(d_raw);
    
    d_sqrt{i} = [sqrt(d_raw{i}(:,1:4)), d_raw{i}(:,5:end)];
    warning off;
    d_log{i} = [log(d_raw{i}(:,1:4)), d_raw{i}(:,5:end)];
    warning on;
    d_log{i}(d_log{i}==-Inf) = 0;
    d_had{i} = [d_raw{i}(:,1:4)*h4, d_raw{i}(:,5:end)];    
end

input.data{2} = d_sqrt;
input.data{3} = d_log;
input.data{4} = d_had;

input.method{1} = 'Raw Amplitude';
input.method{2} = 'Square Root';
input.method{3} = 'Log';
input.method{4} = 'Hadamard';

input.param.amp_kw{1} = [30 30 30 30];
input.param.amp_kw{2} = [.71 .71 .71 .71];
input.param.amp_kw{3} = [.15 .15 .15 .15];
input.param.amp_kw{4} = [40 40 40 40];

input = rmfield(input, 'raw_amps');

%% COMPUTE THE ESTIAMTE
matlabpool('open', 7);
for i=1:numel(input.data)
    tic;
    disp(['Decoding scaling fn: ', input.method{i}]);
    [output.est{i} output.tbins output.pbins] = ...
        decode_amplitudes_par(input.data{i}, input.pos.lp', input.t_range, input.d_range, ...
        'amp_kw', input.param.amp_kw{i});    
    toc;
end
matlabpool('close');
%% Compute Statistics
[output.stats.errors output.stats.me] =...
    calc_recon_errors(output.est, output.tbins, output.pbins, input.pos);
[output.stats.mi output.stats.mi_var] =...
    calc_recon_mi(output.est, output.tbins, output.pbins, input.pos);

%% save the data

if saveData == 1
    curDir = pwd;
    cd ('/data/amplitude_decoding');
    
    filename = ['Amp.Decoding.Scaling.Fn.', animal,'.',date, '.mat'];

    save(filename, 'input', 'output');
    
    cd(curDir)
    clear curDir
end