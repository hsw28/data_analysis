function varargout = jp_load_multiunit(animal, day, epoch, regions, varargin)
%JP_LOAD_MULTIUNIT loads multi-unit data from disk
%
%   MU = JP_LOAD_MULTIUNIT( animal, day, epoch, region)
%   Load the multi-unit data for the specified animal/day/epoch/region(s)
%   animal: a string containing the animals name
%   day:    a string or integer formatted as DDMMYY
%   epoch:  a string containing the name of the desired epoch
%   region: a single string or cell array of strings
%
%   hpcMu  = jp_load_multiunit('blue', '032213', 'sleep2', 'HPC');
%
%   Each region is returned seperately when multiple regions are specified
%
%   [h,c]    = jp_load_multiunit('blue', '032213', 'sleep2', {'HPC', 'RSC'});
%   [h,c,t] = jp_load_multiunit('blue', '032213', 'sleep2', {'HPC', 'RSC', 'THAL'});
%
%   MU = JP_LOAD_MULTIUNIT( animal, day, epoch, region, 'KEY', VAL)
%       CALC_RATE : calclute the TT and regional MU Rate when equal to 1 (Default 1)
%       RATE_DT   : bin width for computing MU Rate (Default .01)
%       SMOOTH    : smooth the multi-unit rate when equal to 1 (Default 1)
%       SMOOTH_DT : width of kernel to use for smoothin (Default .01)

ARGS.CALC_RATE = 1;
ARGS.RATE_DT = .01;
ARGS.SMOOTH = 1;
ARGS.SMOOTH_DT = .01;
ARGS = parseArgs(varargin, ARGS);

edir = jp_working_dir(animal, day);

epochTime = jp_load_epoch(edir, epoch);

if isempty(epochTime)
    error('The specified epoch: %s could not be found in: %s/epoch.epoch', epoch, edir)
end

if ~exist(edir,'dir')
    warning('%s does not exist');
end

if ~iscell(regions)
    regions = {regions};
end

if ~all( cellfun(@(x) any( strcmp( jp_list_valid_regions(), x)), regions))
    error('Invalid list of regions provided. Acceptable options are: HPC, RSC, THAL');
end
    
ttAnatData = jp_load_tt_anatomy(animal, day);
if isempty(ttAnatData)
    error('No anatomy data defined for:%s', edir);
end

ttList = cell2mat( ttAnatData(:, 1 ) ); %#ok ignored variable
ttAnatomy = ttAnatData(:,2);


%% Load all MultiUnit data from Disk
MUA = jp_import_mu(edir);

%% Iterate over each region

nRegion = numel(regions);
varargout = cell( nargout, 1);

if nRegion ~= nargout
    warning('%d regions specified but %d will be returned', nRegion, nargout);
end

for iRegion = 1 : min(nRegion, nargout)
    region = regions{iRegion};
       
    ttLoadList = find( strcmp( ttAnatomy, region ) );



    clustTT = str2double( cellfun( ... 
            @(x) ( getfield(x, 'comp')), MUA.clust,'UniformOutput', 0)' ); %#ok

    clustDiscardIdx = ~ismember(clustTT, ttLoadList);
    
    mua = MUA;
    mua.clust(clustDiscardIdx) = [];
    mua.nclust = numel(mua.clust);

    if ARGS.CALC_RATE == 1
        mua = jp_calc_mu_rate(mua, epochTime, ARGS.RATE_DT);

        if ARGS.SMOOTH == 1
            mua.rate = smoothn(mua.rate, ARGS.RATE_DT, ARGS.SMOOTH_DT );
        end
    end
    
    mua.region = region;
    varargout{iRegion} = mua;
    
end

end