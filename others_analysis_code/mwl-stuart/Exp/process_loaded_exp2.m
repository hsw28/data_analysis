function [exp args] = process_loaded_exp2(exp, varargin)
%% EXP = PROCESS_LOADED_EXP(exp, varargin)
%
% processes the loaded exp data structure. Processing can be modified by
% specifiying which operations to perform. Operations are specified in a
% key/value pair such as 'operations', [1,2,3,6,10];
% to see a list of valid operations type help operations_definitions.
%
% see also loadexp operation_definitions

if nargin<1
    help process_loaded_exp
    return
end

if isvector(varargin{1}) && ~ischar(varargin{1})
    varargin = {'operations', varargin{:}};
end

args.operations = 1:10;

args.epochs = exp.epochs;


args.tc.pos_bw = .1;
args.tc.smooth_kw = .1;
args.tc.pos_fs = 1/30;
args.tc_time_win = [-Inf Inf];

tmp = dset_get_standard_args;
args.mu.dt = tmp.multiunit.dt;
args.mu.kw = tmp.multiunit.smooth_dt;

args = parseArgsLite(varargin, args);

args.operations = operation_definitions( args.operations ); %{'calc_tc', 'load_tetrode_anatomy', 'sort_clusters', 'calc_local_mu', 'calc_mu_bursts'd};

if any(~strcmp(args.epochs, exp.epochs))
    error('invalid epoch specified');
end


for i=1:numel(args.epochs)
    e = args.epochs{i};
%     disp(['PROCESSING EXP']);

%% Calculate Place fields for each cluster
    if any( strcmp('calc_tc', args.operations))
        if isfield(exp.(e),'pos') && isfield(exp.(e),'cl')
             disp([e, ': computing place fields']);

            cl = exp.(e).cl;
            for i=1:length(cl)
                [cl(i).tc1, cl(i).tc2] =...
                    calc_exp_tc(cl(i).st, exp.(e).pos, args.tc.pos_fs, ...
                    args.tc.pos_bw, args.tc.smooth_kw, 'time_win', args.tc_time_win);
                cl(i).tc_bw = args.tc.pos_bw;
                cl = orderfields(cl);
            end
            exp.(e).cl = cl;
        else
            warning('exp is missing clusters or position, both are required to calculate tuning curves');
        end            
    end    
%% Calculate Global Multi-Unit Rate
    if any( strcmp('calc_global_mu', args.operations))
        disp([e,': loading global multi-unit']);
        
        tbins = exp.(e).et(1):args.mu.dt: (exp.(e).et(2) - args.mu.dt);

        muSpikeTimes = load_exp_mu(exp.edir, e);
        exp.(e).mu.global = histc( muSpikeTimes, tbins);
        exp.(e).mu.global = smoothn( exp.(e).mu.global, args.mu.kw, args.mu.dt)/args.mu.dt;
%         exp.(e).mu.global = smoothn(histc(exp.(e).mu.global,tbins), args.mu.kw, args.mu.dt)/args.mu.dt;
        exp.(e).mu.ts = tbins;
    end
%% Calculate Local Multi-Unit Rates
    if any( strcmp('calc_local_mu', args.operations))
        
        disp([e,': loading local multi-unit']);
        
        [tt, loc] = load_exp_tt_anatomy(exp.edir);
        anat = unique(loc);
        
        if ~exist('tbins', 'var')
            tbins = exp.(e).et(1):args.mu.dt: (exp.(e).et(2) - args.mu.dt);
        end
        for a = 1:numel(anat)
            ind = ismember(loc,anat(a));
            disp([e, ': loading multi-unit rate from: ', anat{a}]);
            wave = load_exp_mu(exp.edir, e, 'ignore_tetrode', tt(~ind));
            wave = histc(wave,tbins);
            if ~isempty(wave)
%                 wave( wave>(mean(wave)+10*std(wave)))=mean(wave);
                exp.(e).mu.(anat{a}) = smoothn(wave, args.mu.kw, args.mu.dt)/args.mu.dt;
                exp.(e).mu.ts = tbins;
            else
                exp.(e).mu.(anat{a}) = nan;
            end
        end
        
    end
%% Calculate Multi Unit Bursts
    if any( strcmp('calc_mu_bursts', args.operations))
        if isfield(exp.(e),'mu')
               disp([e, ': calculating multi-unit bursts']);
               fn = fieldnames(exp.(e).mu);
               for f = 1:numel(fn)
                   if ~any( strcmp(fn{f}, {'global', 'left', 'right'}) )
                       continue;
                   end
                   
                   p = [];
                   
                   if isfield(exp.(e),'pos')
                       p = exp.(e).pos;
                   end
                   
%                    bt = find_mu_burst(  exp.(e).mu.(fn{f}), ...
%                                                 exp.(e).mu.ts, ...
%                                                 p);
                   bt = exp_find_mua_bursts(exp.(e).mu.(fn{f}), ...
                                                  exp.(e).mu.ts,...
                                                  'pos_struct', p);
                   if strcmp(fn{f}, 'global')
                       exp.(e).mu.bursts = bt;
                   else
                       exp.(e).mu.([fn{f},'_bursts']) = bt;
                   end
                   
               end
        else
            warning('structure does not have a multiunit field, which is required to calculate mub');
        end
  
    end
%% Calculate Global Ripple Bursts
    if any( strcmp('calc_global_rip', args.operations))
        warning('Calculate Global Ripple Bursts is not implemented');
    end
%% Calculate Local Ripple Bursts
    if any( strcmp('calc_local_rip', args.operations))
        warning('Calculate Local Ripple Bursts is not implemented');
    end
%% Load Tetrode Anatomy
    if any( strcmp('load_tetrode_anatomy', args.operations)) && isfield(exp.(e),'cl') 
       disp([e, ': loading tetrode anatomy']);
      
       [tt, loc] = load_exp_tt_anatomy(exp.edir);
        for cn=1:numel(exp.(e).cl)
            
            ind = find(strcmp( {exp.(e).cl(cn).tt}, tt ));
            exp.(e).cl(cn).loc = loc{ind};
        end
    end
%% Load EEG Anatomy
    if any( strcmp('load_eeg_anatomy', args.operations))
       disp([e, ': loading eeg anatomy']);
       if ~exist(fullfile(exp.edir, 'eeg_anatomy.mat'),'file')
           f = define_exp_eeg_anatomy(exp.edir);           
           waitfor(f);
       end
       
       [eeg, loc] = load_exp_eeg_anatomy(exp.edir);
        for cn=1:numel(exp.(e).eeg.loc);
            ind = find(strcmp( exp.(e).eeg.ch(cn), eeg) );
            exp.(e).eeg.loc{cn} = loc{ind};
        end
    end
%% Sort Clusters by Tuning Curve
    if any( strcmp('sort_clusters', args.operations))
        warning('Cluster Sorting is not yet implemented');
    end
%% Calculate Cluster Stats
    if any( strcmp('calc_cl_stats', args.operations))
        warning('Calculate cluster stats is not yet implemented');
    end
    
    
    
end
