function [exp args] = process_loaded_exp(exp, varargin)
%% EXP = PROCESS_LOADED_EXP(exp, varargin)
%
% processes the loaded exp data structure. Processing can be modified by
% specifiying which operations to perform. Operations are specified in a
% key/value pair such as 'operations', [1,2,3,6,10];
% to see a list of valid operations type help operations_definitions.
%
% see also loadexp operation_definitions

warning('USE process_loaded_exp2 instead!');
if nargin<1
    help process_loaded_exp
    return
end

args.operations = 1:10;

args.epochs = exp.epochs;

args.tc.pos_bw = .1;
args.tc.smooth_kw = .1;
args.tc.pos_fs = 1/30;
args.tc_time_win = [-Inf Inf];

args.mu.dt = .001;
args.mu.kw = .001;

args = parseArgsLite(varargin, args);

args.operations = operation_definitions(args.operations);

if any(~ismember(args.epochs, exp.epochs))
    error('invalid epoch specified');
end

for i=1:numel(args.epochs)
    e = args.epochs{i};
    disp(['PROCESSING EXP']);

%% Calculate Place fields for each cluster
    if ismember('calc_tc', args.operations);
        if isfield(exp.(e),'pos') && isfield(exp.(e),'cl') && ~isempty( fieldnames(exp.(e).cl))
           
            disp([10, e, ': computing place fields']);

            cl = exp.(e).cl;
            for i=1:length(cl)
                [cl(i).tc1 cl(i).tc2] =...
                    calc_exp_tc(cl(i).st, exp.(e).pos, args.tc.pos_fs, ...
                    args.tc.pos_bw, args.tc.smooth_kw, 'time_win', args.tc_time_win);
                cl(i).tc_bw = args.tc.pos_bw;
                cl = orderfields(cl);
            end
            exp.(e).cl = cl;
        else
            warning('exp is missing clusters or position, both are required to calculate tuning curves');
        end   
        return
    end    
%% Calculate Global Multi-Unit Rate
    if ismember('calc_global_mu', args.operations)
        disp([e,': loading global multi-unit']);
        exp.(e).mu.global = load_exp_mu(exp.edir, e);
        tbins = exp.(e).et(1):args.mu.dt:exp.(e).et(2);
        exp.(e).mu.global = smoothn(histc(exp.(e).mu.global,tbins), args.mu.kw, args.mu.dt)/args.mu.dt;
        exp.(e).mu.ts = tbins;
    end
%% Calculate Local Multi-Unit Rates
    if ismember('calc_local_mu', args.operations)
        disp([e,': loading local multi-unit']);
        [tt loc] = load_exp_tt_anatomy(exp.edir);
        anat = unique(loc);
        tbins = exp.(e).et(1):args.mu.dt:exp.(e).et(2);
        for a = 1:numel(anat)
            ind = ismember(loc,anat(a));
            disp([e, ': loading multi-unit rate from: ', anat{a}]);
            wave = load_exp_mu(exp.edir, e, 'ignore_tetrode', tt(~ind));
            wave = histc(wave,tbins);
            if ~isempty(wave)
                wave(wave>(mean(wave)+10*std(wave)))=mean(wave);
                exp.(e).mu.(anat{a}) = smoothn(wave, args.mu.kw, args.mu.dt)/args.mu.dt;
                exp.(e).mu.ts = tbins;
            else
                exp.(e).mu.(anat{a}) = nan;
            end
        end
        
    end
%% Calculate Multi Unit Bursts
    if ismember('calc_mu_bursts', args.operations);
        if isfield(exp.(e),'mu')
               disp([e, ': calculating multi-unit bursts']);
               fn = fieldnames(exp.(e).mu);
               for f = 1:numel(fn)
                   if strcmp(fn{f}, 'ts')
                       continue;
                   end
                   disp(fn{f});
                   p = [];
                   if isfield(exp.(e),'pos')
                       p = exp.(e).pos;
                   end
                   [bt lt ht] = find_mu_burst(  exp.(e).mu.(fn{f}), ...
                                                exp.(e).mu.ts, ...
                                                p);
                   exp.(e).mu.([fn{f},'_bursts']) = bt;
                   
               end
        else
            warning('structure does not have a multiunit field, which is required to calculate mub');
        end
  
    end
%% Calculate Global Ripple Bursts
    if ismember('calc_global_rip', args.operations)
        warning('Calculate Global Ripple Bursts is not implemented');
    end
%% Calculate Local Ripple Bursts
    if ismember('calc_local_rip', args.operations)
        warning('Calculate Local Ripple Bursts is not implemented');
    end
%% Load Tetrode Anatomy
    if ismember('load_tetrode_anatomy', args.operations) && isfield(exp.(e),'cl') && ~isempty(fieldnames(exp.(e).cl))
       disp([e, ': loading tetrode anatomy']);
      
       [tt loc] = load_exp_tt_anatomy(exp.edir);
        for cn=1:numel(exp.(e).cl);
            [x ind] = ismember({exp.(e).cl(cn).tt}, tt);
            exp.(e).cl(cn).loc = loc{ind};
        end
    end
%% Load EEG Anatomy
    if ismember('load_eeg_anatomy', args.operations)
       disp([e, ': loading eeg anatomy']);
       if ~exist(fullfile(exp.edir, 'eeg_anatomy.mat'),'file')
           f = define_exp_eeg_anatomy(exp.edir);           
           waitfor(f);
       end
       
       [eeg loc] = load_exp_eeg_anatomy(exp.edir);
        for cn=1:numel(exp.(e).eeg.loc);
            [x ind] = ismember(exp.(e).eeg.ch(cn), eeg);
            exp.(e).eeg.loc{cn} = loc{ind};
        end
    end
%% Sort Clusters by Tuning Curve
    if ismember('sort_clusters', args.operations)
        warning('Cluster Sorting is not yet implemented');
    end
%% Calculate Cluster Stats
    if ismember('calc_cl_stats', args.operations)
        warning('Calculate cluster stats is not yet implemented');
    end
    
    
    
end
