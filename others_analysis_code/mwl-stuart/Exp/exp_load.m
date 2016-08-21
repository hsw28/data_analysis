function [exp args] = exp_load(edir, varargin)
%% EXP = LOADEXP(edir, varargin)
%
% loadsset data from disk and creates a unified data structure for all
% experiment data. This structure will probably require further processing
% before use. 
%
% this processing is done by default and can be turned off by passing the
% key/value pair of 'do_processing', 0. Which operations are done can be
% specified for more inforation consult process_loaded_exp and
% operation_def
%
% see also process_loaded_exp, operation_definitions
%

default_operations = [];

args.epochs = {'no epoch specified'};

args.data_types = {};

args.do_processing = 1;
args.operations = default_operations;

args.ignore_tetrode = {'none'};
args.ignore_tetrode_mu = {'none'};
args.ignore_eeg_file = {'none'};
args.ignore_eeg_channel = {'none'};

args = parseArgsLite(varargin, args);


if ~iscell(args.epochs)
    args.epochs = {args.epochs};
end

[en et] = load_epochs(edir);

%check all requested epochs to see if they are valid
for e = 1:numel(args.epochs)
    inter = intersect(en, args.epochs(e));
    if isempty(inter)
        error(['Invalid Epoch Specified: ', args.epochs{e}]);
    end
end
    
% load the actual epoch data
for e = 1:numel(args.epochs)
    ep = args.epochs{e};
    et_sel = et(ismember(en, ep),:);
    exp.(ep) = load_exp_epoch(edir, ep, et_sel, args);
    
end

    exp.edir = edir;
    exp.epochs = args.epochs;
    if args.do_processing & ~isempty(args.operations)
        [exp args.processing_args] = process_loaded_exp(exp,'operations', args.operations);
    end

end


function epoch_data = load_exp_epoch(edir, ep, et, args)
%     args.data_types = {'cells', 'eeg', 'mu', 'pos'};
%     args.ignore_tetrode = {'none'};
%     args.ignore_tetrode_mu = {'none'};
%     args.ignore_eeg_file = {'none'};
%     args.ignore_eeg_channel = {'none'};
% 
%     args = parseArgsLite(varargin, args);

     fprintf('Loading:  %s - %s\n', edir, ep);
    
    if ismember('clusters', args.data_types)
%         fprintf('Loading single units for epoch: %s\n', ep);
        epoch_data.cl = load_exp_clusters(edir, ep, 'ignore_tetrode', args.ignore_tetrode);
    end
    
    if ismember('eeg', args.data_types)
%         fprintf('Loading  for epoch: %s\n', ep);        
        epoch_data.eeg = load_exp_eeg(edir, ep,...
            'ignore_eeg_file', args.ignore_eeg_file, ...
            'ignore_eeg_channel', args.ignore_eeg_channel);
    end
       
%     if ismember('mu', args.data_types)
%         disp(['     Loading multi unit for epoch: ', ep]);        
%         epoch_data.mu.st = load_exp_mu(edir, ep, 'ignore_tetrode_mu', args.ignore_tetrode_mu);
%        
%     end
    
    if ismember('pos', args.data_types)
%         fprintf('Loading position for epoch: \t\n', ep);        
        epoch_data.pos = load_exp_pos(edir, ep);
    end
    

    epoch_data.et = et;
end
