classdef kde_decoder < handle
%KDE_DECODER class for generalized bayesian decoding    
%
%  obj=KDE_DECODER(time,stimulus,spiketimes,spikestimulus) constructs a new
%  kde_decoder object. Time is an ordered vector of times at which the
%  stimulus  (e.g. position, or head direction) is sampled. The stimulus
%  argument is a 2D array in which rows represent time and columns
%  represent the stimulus dimensions. The spiketimes argument is a cell
%  array with in each cell a vector of spike times from a single source
%  (such as a cluster or a tetrode). The spikestimulus argument is a cell
%  array with the corresponding stimulus for each of the sources. 
%
%  obj=KDE_DECODER(time,stimulus,spiketimes,spikestimulus,spikeresponse)
%  also specifies the responses (e.g. spike amplitude) for each of the
%  sources. The spikeresponse argument should be a cell array with in each
%  cell a 2D array of responses.
%
%  obj=KDE_DECODER(...,parm1,val1,...) initialize parameters using optional
%  keyword/value pairs. Valid parameters are:
%   encoding_segments - nx2 list of time epochs. Only stimulus data and
%                       spike data recorded during these epochs is used to
%                       construct the kernel density estimate. (default:
%                       epoch defined by start and end time of the time
%                       vector provided during object construction)
%   stimulus_variable_type - string or cell array of strings with for each
%                            stimulus dimension the type of variable, which
%                            can be one of: 'linear', 'circular' or
%                            'categorical'. (Default: 'linear')
%   stimulus_grid - cell array with for each stimulus dimension a vector of
%                   stimulus values at which the kde is evaluated.
%                   (default: [])
%   stimulus_grid_validity - logical matrix the same size as final PDF
%                            matrix in which all true elements are deemed
%                            invalid and are not computed.
%   stimulus_kernel - string or cell string array with for each stimulus
%                     dimension the type of kernel to use. Choose from:
%                     'gaussian', 'epanechnikov', 'vonmises', 'kronecker'.
%                     Linear variables only support gaussian, epanechnikov
%                     and kronecker delta kernels; circular variables only
%                     support von Mises kernels; categorical variables only
%                     support kronecker delta kernels with a fixed
%                     bandwidth of 0.5. (Default: gaussian)
%   stimulus_bandwidth - scalar or vector of kernel bandwidths for all
%                        stimulus dimensions. For the gaussian kernel, the
%                        bandwidth specifies the standard deviation; for
%                        the von Mises kernel the bandwidth specifies the
%                        concentration parameter kappa; for the
%                        epanechnikov and kronecker delta kernels, the
%                        bandwidth specifies the half width of the total
%                        kernel; for categorical variables using the
%                        kronecker delta kernel, the bandwidth is fixed at
%                        0.5. (Default: 1)
%   response_variable_type - string or cell array of strings with for each
%                            response dimension the type of variable, which
%                            can be one of: 'linear', 'circular' or
%                            'categorical'. (Default: 'linear')
%   response_kernel - string or cell string array with for each response
%                     dimension the type of kernel to use. Choose from:
%                     'gaussian', 'epanechnikov', 'vonmises' or
%                     'kronecker'. (Default: gaussian)
%   response_bandwidth - scalar, vector or cell array with vectors
%                        specifying kernel bandwidths for all response
%                        dimensions. In case of cell array, cells
%                        specify bandwidths for each source.
%   source_selection - a vector with for each source 1 or 0, indicating
%                      whether or not the source should be included in the
%                      computation. (Default: all 1)
%   response_filter - handle to a function that takes the response matrix
%                     and the source index as input arguments and returns a
%                     vector with for each response (i.e. each row) true or
%                     false, to indicate whether or not it should be
%                     included in the computation. This can for example be
%                     used to select on spike amplitude or width.
%                     (Default: @(x,src) true(size(x,1),1) )
%   response_filter_post - 
%   response_transformation - handle to a function that takes the response
%                             matrix and the source index as input
%                             arguments and returns a same-size matrix with
%                             transformed responses. (Default: @(x,src) x)
%   response_selection - scalar, vector or cell array of vectors specifying
%                        which of the response dimensions will be used in
%                        the computation. In case of a cell array, cells
%                        specify the response selection for each source.
%                        (Default: 1)
%   response_randomization - true/false. If true, spike response are
%                            randomized before computing the kde.
%   distance - cell array with for each stimulus dimension either en empty
%              array (standard eucledian distance will be used) or a square
%              matrix with distance between sampled stimulus values. If for
%              a given stimulus dimension a distance matrix is provided,
%              then corresponding columns in the stimulus and spikestimulus
%              arrays should contain indices of the sampled stimulus value.
%              For stimulus dimensions with a discrete kernel, the distance
%              matrix is ignored.
%              (Default: [])
%   rate_modulation - rate modulation factor (Default: 1)
%   rate_offset - offset for rate functions (Default: 0.01Hz)
%   parallel - true/false, parallelize computation. In some case this may
%              speed up the computation if you have configured matlab to
%              use multiple cores, in other cases the overhead of using
%              parallelization could slow down the computation (in
%              particular if you are computing the posterior very often
%              with small test data sets). (Default: true)
%

    properties (Constant=true)
        kernel_types = {'gaussian', 'epanechnikov', 'vonmises', 'kronecker'};
        variable_types = {'linear', 'circular', 'categorical'};
    end
    
    properties (SetAccess=protected)
        training_time
        training_stimulus % Z x Q
        spike_time
        spike_stimulus % cell array, Ni x Q
        spike_response % cell array, Ni x Di
        distance_lut % length Q cell array with square matrices

        stimulus_variable_type
        response_variable_type
        
        state = struct( 'stimulus_kernel', [], ...
            'response_kernel', {{}}, ...
            'stimulus_bandwidth', [], ...
            'response_bandwidth', {{}}, ...
            'source_selection', [], ...
            'response_selection', {{}}, ...
            'stimulus_grid', [], ...
            'stimulus_grid_validity', [], ...
            'response_randomization', false, ...
            'response_transformation', @(x) x, ...
            'response_filter', @(x) true(size(x,1),1), ...
            'response_filter_post', @(x) true(size(x,1),1), ...
            'encoding_segments', zeros(0,2), ...
            'rate_modulation', 1, ...
            'rate_offset', 0.01)
        
        stimulus_grid_expanded
        
    end
    
    properties (Access=protected, Hidden=true)
        initialized = false;
        
        index_cache = struct( 'state', struct('encoding_segments', NaN), 'training', NaN, 'spike', NaN )
        response_filter_cache = struct( 'state', struct('response_filter', NaN), 'data', NaN )
        spike_stimulus_cache = struct( 'state', struct('stimulus_kernel', NaN, 'stimulus_bandwidth', NaN, 'encoding_segments', NaN, 'response_filter', NaN), 'data', NaN );
        spike_response_cache = struct( 'state', struct('response_transformation', NaN, 'response_kernel', NaN, 'response_bandwidth', NaN, 'encoding_segments', NaN, 'response_filter', NaN), 'data', NaN );
        distance_cache = struct( 'state', struct('stimulus_kernel', NaN, 'stimulus_bandwidth', NaN), 'data', NaN );
        marginal_cache = struct( 'state', struct('stimulus_kernel', NaN, 'stimulus_bandwidth', NaN), 'stimulus', NaN, 'spike_stimulus', NaN );
        
        flag_index_cache = true;
        flag_response_filter_cache = true;
        flag_stimulus_cache = true;
        flag_response_cache = true;
        flag_distance_cache = true;
        flag_marginal_cache = true;
        
    end
    
    properties (Dependent=true)
        response_randomization
        response_transformation
        response_filter
        response_filter_post
        stimulus_kernel
        response_kernel
        stimulus_bandwidth
        response_bandwidth
        source_selection
        response_selection
        stimulus_grid
        stimulus_grid_validity
        encoding_segments
        rate_modulation
        rate_offset
    end
   
    properties (Dependent=true, SetAccess=protected)
        ndim_stimulus
        ndim_response
        nsources
        nspikes
        mean_rate
        stimulus_grid_size
        current_state
        training_duration
        stimulus_marginal
        spike_stimulus_marginal
    end
    
    properties
        parallel = true
    end
    
    methods
        
        %CONSTRUCTOR
        function obj=kde_decoder( varargin )
            
            obj.initialized = false;
            
            %parse keyword/value arguments
            options = struct( 'encoding_segments', [-Inf Inf], 'distance', [], 'stimulus_kernel', 'gaussian', 'stimulus_bandwidth', 1, 'response_kernel', 'gaussian', 'response_bandwidth', 1, ...
                'source_selection', true, 'response_selection', true, 'response_randomization', false, 'response_transformation', [], 'response_filter', [], 'response_filter_post', [], ...
                'stimulus_grid', [], 'stimulus_grid_validity', [], 'parallel', true, 'rate_modulation', 1, 'rate_offset', 0.01, 'stimulus_variable_type', 'linear', 'response_variable_type', 'linear' );
            
            [options,other] = parseArgs( varargin, options );
            
            %check non-keyword, immutable arguments
            if numel(other)<4
                err = MException('kde_decoder:kde_decoder:invalidArgument', 'Need at least 4 arguments');
                throw(err);
            end
            
            if ~isnumeric(other{1}) || ~isvector(other{1}) || isempty(other{1}) || ~issorted(other{1})
                err = MException('kde_decoder:kde_decoder:invalidArgument','Training time should be a vector');
                throw(err);
            else
                obj.training_time = other{1}(:);
            end
            
            if ~isnumeric(other{2}) || ndims(other{2})~=2 || size(other{2},1)~=numel(obj.training_time)
                err = MException('kde_decoder:kde_decoder:invalidArgument','Training stimulus should be a 2D array');
                throw(err);
            else
                obj.training_stimulus = other{2};
            end
            
            ndim_stim = size(obj.training_stimulus,2);
            
            if ~iscell(other{3}) || ~isvector(other{3}) || any( cellfun( @(x) ~isnumeric(x) || ~isvector(x) || isempty(x) || ~issorted(x), other{3} ) )
                err = MException('kde_decoder:kde_decoder:invalidArgument','Spike time should be a cell array with sorted vectors');
                throw(err);
            else
                obj.spike_time = other{3}(:);
            end
            
            nsrc = numel(obj.spike_time);
            
            if ~iscell(other{4}) || ~isvector(other{4}) || numel(other{4})~=nsrc || any( cellfun( @(x) ~isnumeric(x) || ndims(x)~=2 || isempty(x) || size(x,2)~=ndim_stim, other{4} ) )
                err = MException('kde_decoder:kde_decoder:invalidArgument','Spike stimulus should be a cell array with 2D arrays');
                throw(err);
            else
                obj.spike_stimulus = other{4}(:);
            end           
            
            if numel(other)<5 || isempty(other{5})
                obj.spike_response = cell( nsrc, 1 );
                for j=1:nsrc
                    obj.spike_response{j} = zeros( size(obj.spike_stimulus{j},1) , 0 );
                end
            elseif ~iscell(other{5}) || ~isvector(other{5}) || numel(other{5})~=nsrc || any( cellfun( @(x,y) ~isnumeric(x) || ndims(x)~=2 || size(x,1)~=size(y,1), other{5}(:), obj.spike_stimulus ) )
                err = MException('kde_decoder:kde_decoder:invalidArgument','Spike response should be a cell array with 2D arrays');
                throw(err);
            else
                obj.spike_response = other{5}(:);
            end
            
            %set keyword parameters
            obj.encoding_segments = options.encoding_segments;
            
            %variable types are immutable, so let's check it here
            if isempty(options.stimulus_variable_type)
                obj.stimulus_variable_type = ones(1,obj.ndim_stimulus);
            elseif ischar( options.stimulus_variable_type ) || (iscellstr(options.stimulus_variable_type) && numel(options.stimulus_variable_type)==obj.ndim_stimulus)
                val = obj.validate_vartypes( options.stimulus_variable_type );
                obj.stimulus_variable_type = ones(1,obj.ndim_stimulus).*val(:)';
            else
                err = MException('kde_decoder:kde_decoder:invalidArgument','Variable type should be specified as a string or cell array of strings');
                throw(err);
            end
            
            %let's round any categorical stimulus dimensions to integers
            idx = obj.stimulus_variable_type==3;
            obj.training_stimulus(:,idx) = round( obj.training_stimulus(:,idx) );
            
            for j=1:nsrc
                obj.spike_stimulus{j}(:,idx) = round( obj.spike_stimulus{j}(:,idx) );
            end
            
            val = options.response_variable_type;
            if ischar(val) || isempty(val)
                val = obj.validate_vartypes( val );
                for j=1:nsrc
                    obj.response_variable_type{j,1} = ones(1,obj.ndim_response(j)).*val;
                end
            elseif iscellstr(val) && isequal( size(val), [1 obj.ndim_response(1)]) && isscalar( unique( obj.ndim_response ) )
                val = obj.validate_vartypes( val );
                obj.response_variable_type = cell(nsrc,1);
                [obj.response_variable_type{1:nsrc,1}] = deal(val);
            elseif iscellstr(val) && isequal( size(val), [nsrc obj.ndim_response(1)]) && isscalar( unique( obj.ndim_response ) )
                val = obj.validate_vartypes( val );
                for j=1:nsrc
                    obj.response_variable_type{j,1} = val(j,:);
                end
            elseif iscell(val) && isequal( size(val), [nsrc 1] )
                for j=1:nsrc
                    tmp = obj.validate_vartypes( val{j} );
                    if ~isscalar(tmp) && numel(tmp)~=obj.ndim_response(j)
                        err = MException('kde_decoder:kde_decoder:invalidArgument','Invalid response variable type');
                        throw(err);
                    end
                    obj.response_variable_type{ j,1 } = ones(1,obj.ndim_response(j)).*tmp(:)';
                end
            else
                err = MException('kde_decoder:kde_decoder:invalidArgument','Invalid response variable type');
                throw(err)
            end
            
            %let's round any categorical response dimensions to integers
            for j=1:nsrc
                idx = obj.response_variable_type{j}==3;
                obj.spike_response{j}(:,idx) = round( obj.spike_response{j}(:,idx) );
            end
            
            %distance LUT is immutable, hence we check it here
            if isempty(options.distance)
                obj.distance_lut = cell(1,ndim_stim);
            elseif ~iscell(options.distance) || ~isvector(options.distance) || numel(options.distance)~=ndim_stim || any( cellfun(@(x) (ndims(x)~=2 || size(x,1)~=size(x,2)) && ~isempty(x), options.distance ) )
                err = MException('kde_decoder:kde_decoder:invalidArgument', 'Invalid distance lookup tables');
                throw(err);
            else
                ni = cellfun( @(x) size(x,1), options.distance(:)' );
              
                %categorical variable cannot have a distance matrix
                idx = obj.stimulus_variable_type==3 & ni>0;
                if sum(idx)>0
                    warning('kde_decoder:kde_decoder:invalidOption', 'Distance matrix is not supported for categorical stimulus dimensions')
                    [options.distance{idx}] = deal([]);
                    ni(idx) = 0;
                end
                
                %check validity of training_stimulus and spike_stimulus
                %these should be indices into the distance LUTs
                idx = ni>0;
                if sum(idx)>0
                    %round to nearest integer
                    obj.training_stimulus(:,idx) = round( obj.training_stimulus(:,idx) );
                    for k=1:ndim_stim
                        obj.spike_stimulus{k}(:,idx) = round( obj.spike_stimulus{k}(:,idx) );
                    end
                    %check validity of indices
                    if any( any( bsxfun( @ge, obj.training_stimulus(:,idx), ni(idx) ) | obj.training_stimulus(:,idx)<0 ) ) || ...
                            any( cellfun( @(x) any( any( bsxfun( @ge, x(:,idx), ni(idx) ) | x(:,idx)<0 ) ), obj.spike_stimulus ) )
                        err = MException('kde_decoder:kde_decoder:invalidArgument', 'Index out of range for stimulus dimensions with a distance lookup table');
                        throw(err);
                    end
                end
                
                obj.distance_lut = options.distance;
            end
            
            obj.response_randomization = options.response_randomization;
            obj.response_transformation = options.response_transformation;
            obj.response_filter = options.response_filter;
            obj.response_filter_post = options.response_filter_post;
            obj.stimulus_kernel = options.stimulus_kernel;
            obj.response_kernel = options.response_kernel;
            obj.stimulus_bandwidth = options.stimulus_bandwidth;
            obj.response_bandwidth = options.response_bandwidth;
            obj.source_selection = options.source_selection;
            obj.response_selection = options.response_selection;
            obj.stimulus_grid = options.stimulus_grid;
            obj.stimulus_grid_validity = options.stimulus_grid_validity;
            obj.parallel = options.parallel;
            obj.rate_modulation = options.rate_modulation;
            obj.rate_offset = options.rate_offset;
                     
        end
        
        %INFORMATION METHODS
        function display(obj)
            
            s = sprintf( 'kde decoder object with %d source%s', obj.nsources, plural(obj.nsources) );
            disp(s)
            s = sprintf( 'with %d stimulus dimension%s, evaluated on a %s size grid', obj.ndim_stimulus, plural(obj.ndim_stimulus), mat2str(obj.stimulus_grid_size) );
            disp(s) 
            
        end
        function info(obj)
            
            disp('kde decoder object')
            fprintf(' total data time = %0.2f seconds\n', diff( obj.training_time([1 end]) ) );
            fprintf(' duration of encoding segments = %0.2f seconds (%0.1f%%) across %d segment%s\n', obj.training_duration, 100*obj.training_duration./diff( obj.training_time([1 end]) ), size(obj.encoding_segments,1), plural(size(obj.encoding_segments,1) ) );
            
            disp(' ')
            
            % # sources, number of spikes, mean rate, source selection
            fprintf(' contains %d source%s\n', obj.nsources, plural(obj.nsources) );
            fprintf('   selected sources = %s\n', mat2str( find( obj.source_selection(:)' ) ) );
            fprintf('   # spikes per source = %s\n', mat2str( obj.nspikes(:)', 3 ) );
            fprintf('   mean rate per source = %s\n', mat2str( obj.mean_rate(:)', 3 ) );
            
            % rate modulation
            tmp = unique( obj.rate_modulation );
            if isscalar(tmp)
                fprintf( '   rate modulation = %0.2f\n', tmp )
            else
                fprintf( '   rate modulation = %s\n', mat2str(obj.rate_modulation(:)',3) )
            end
            
            disp(' ')
            
            %stimulus
            % # dimensions, variable types, kernels, bandwidths, distance LUTs
            fprintf(' stimulus has %d dimension%s\n', obj.ndim_stimulus, plural(obj.ndim_stimulus) );
            fprintf('   %3s %12s %10s %10s %12s\n', 'dim', 'var. type', 'kernel', 'bandwidth', 'distance LUT' );
            for k=1:obj.ndim_stimulus
                fprintf('   %3d %12s %10s %10.3f %12s\n', k, obj.variable_types{ obj.stimulus_variable_type(k) }, obj.kernel_types{ obj.stimulus_kernel(k) }, obj.stimulus_bandwidth(k), onoff( isempty(obj.distance_lut{k}), { 'no' sprintf('yes (size=%d)', size(obj.distance_lut{k},1) ) } ) );
            end

            disp(' ')
            
            % stimulus grid
            fprintf( ' stimulus grid size = %s\n', mat2str(obj.stimulus_grid_size) );
            
            disp(' ')
            
            %response
            % # dimensions, variable types, kernels, bandwidths
            % response_selection
            
            
            if all(obj.ndim_response==0)
                fprintf(' no responses\n')
            else
                tmp = cat(2,obj.response_selection, obj.response_variable_type, obj.response_kernel, obj.response_bandwidth );
                
                tmp_str = cellfun( @(x)(mat2str(x)), tmp, 'UniformOutput',false);
                tmp_str2 = cell(obj.nsources,1);
                for s=1:obj.nsources
                    tmp_str2{s} = [ tmp_str{s,:} ];
                end
                
                [~, jj, ii] = unique( tmp_str2 );
                tmp = tmp(jj,:);
                
                fprintf(' responses\n' );
                for s=1:size(tmp,1)
                    fprintf('   source%s %s\n', plural(sum(ii==s)), mat2str(find(ii(:)'==s)));
                    fprintf('   %3s %12s %10s %10s\n', 'dim', 'var. type', 'kernel', 'bandwidth' );
                    for k=1:numel(tmp{s,1})
                        fprintf('   %s%2d %12s %10s   %6.3f\n', onoff(tmp{s,1}(k), {'*', ' '}), k, obj.variable_types{ tmp{s,2}(k) }, obj.kernel_types{ tmp{s,3}(k) }, tmp{s,4}(k) );
                    end
                    fprintf('\n');
                end
                
            end
            
            disp(' ')
            
            fprintf(' randomization of responses = %s\n', onoff( obj.response_randomization ) );
            fprintf(' response transformation function = %s\n', func2str( obj.response_transformation ) );
            fprintf(' response filter function = %s\n', func2str( obj.response_filter ) );
            fprintf(' response filter post function = %s\n', func2str( obj.response_filter_post ) );

            disp(' ')
            
            %rate offset
            fprintf( ' rate offset = %0.3f\n', obj.rate_offset );
            
            %functions used
            s = cell(obj.nsources,1);
            for j=1:obj.nsources
                [~,s{j}] = kde_decoder.get_func( obj.stimulus_kernel, obj.response_kernel{j} );
            end
            s = unique(s);
            
            fprintf( ' mex function%s used = %s\n', plural(numel(s)), sprintf( '%s ', s{:}))
            
            %parallel
            fprintf( ' parallelization = %s\n', onoff( obj.parallel && matlabpool('size')>1 ) )
            
            disp(' ')
            
        end

        %COMPUTATION METHODS
        function [P,E,info] = compute( obj, bins, varargin )
            
            %check arguments
            options = struct( 'use_marginal', false );
            [options,other,remainder] = parseArgs( varargin, options );
            
            %compute log(rate) and marginal rate for all sources
            [P,M,info] = obj.compute_sources( bins, other{:}, remainder{:} );
            
            %compute posterior distribution
            P = obj.compute_posterior( P, M, diff( bins, [], 2 ) );

            if nargout>1
                %compute decoding performamce
                if numel(other)==0
                    true_stim = interp1( obj.training_time, obj.training_stimulus, mean( bins, 2 ), 'nearest' );
                    E = obj.compute_performance( true_stim, P, options.use_marginal );
                else
                    %user provided own spike times and responses, the true
                    %stimulus is (probably) unknown, so issue a warning
                    E = [];
                    warning('kde_decoder:compute:cannotCompute', 'Unable to compute performance if custom spike times/responses are provided')
                end
                
            end
            
        end
        function [P,M,info] = compute_sources(obj,bins,timestamp,testresponse)
            
            %get which sources to compute
            currentstate = obj.state(end);
            src_idx = find( currentstate.source_selection );
            
            %get stimulus grid and mask invalid elements
            stimgrid = obj.stimulus_grid_expanded;
            if ~isempty(currentstate.stimulus_grid_validity)
                stimgrid( currentstate.stimulus_grid_validity,:) = NaN;
            end
            
            %get spike stimulus and response
            sp_stimulus = get_spike_stimulus_cache(obj);
            sp_stimulus = sp_stimulus( src_idx );
            
            sp_response = get_spike_response_cache(obj);
            sp_response = sp_response( src_idx );
            
            %get distance matrices
            dist_lut = get_distance_cache(obj);
            
            nsrc = numel(src_idx);
            
            if nargin==2
                %use spike times and responses stored in object
                timestamp = obj.spike_time( src_idx );
                testresponse = obj.spike_response( src_idx );
                flt_idx = obj.get_response_filter_cache();
                flt_idx = flt_idx(src_idx);
            else
                %use spike times and responses provided in arguments
                flt_idx = cell(nsrc,1);
            end
            
            %pre-allocate arrays
            P = cell( nsrc, 1 );
            M = cell( nsrc, 1 );
            
            nspikes = zeros( nsrc, 1 );
            ntestspikes = zeros( nsrc, 1 );
            nrespdim = zeros( nsrc, 1 );
            
            %get stimulus marginal
            stim_marginal = obj.get_stimulus_marginal_cache();
            training_duration = obj.training_duration;
            
            %compute log(rate) and marginal rate for all sources
            if obj.parallel && matlabpool('size')>1
                
                parfor src = 1:numel(src_idx)
                    
                    [P{src},M{src},nspikes(src),ntestspikes(src),nrespdim(src)] = compute_source(src_idx(src), bins, timestamp{src}, testresponse{src}, sp_stimulus{src}, sp_response{src}, stimgrid, currentstate, dist_lut, stim_marginal, training_duration, flt_idx{src});
                    
                end
                
            else
                
                for src = 1:numel(src_idx)
                    
                    [P{src},M{src},nspikes(src),ntestspikes(src),nrespdim(src)] = compute_source(src_idx(src), bins, timestamp{src}, testresponse{src}, sp_stimulus{src}, sp_response{src}, stimgrid, currentstate, dist_lut, stim_marginal, training_duration, flt_idx{src});
                    
                end
                
            end
               
            info = struct( 'nspikes', nspikes, 'ntestspikes', ntestspikes, 'nrespdim', nrespdim );
            
            
        end
        function P = compute_posterior( obj, P, M, delta, rate_modulation )
        %COMPUTE_POSTERIOR compute posterior distribution
        
            if nargin<5 || isempty(rate_modulation)
                rate_modulation = obj.rate_modulation( obj.source_selection );
            elseif isscalar(rate_modulation)
                rate_modulation = rate_modulation.*ones(numel(P),1);
            elseif numel(rate_modulation)~=numel(P)
                error('kde_decoder:invalidArgument', 'Invalid rate modulation vector')
            end
            
            Psum = 0;
            Msum = 0;
            
            %sum log(rates) and marginal rates
            if iscell( P ) && iscell(M)
                for k=1:numel(P)
                    Psum = Psum + P{k};
                    Msum = Msum + rate_modulation(k) .* M{k};
                end
            else
                Psum = P;
                Msum = M;
            end
                
            %compute likelihood
            P = bsxfun( @minus, Psum, bsxfun( @times, delta(:), Msum ) );
            %normalize
            P = exp( bsxfun( @minus, P, nanmax(P,[],2) ) );
            P = bsxfun( @rdivide, P, nansum(P,2) );
            
            %reshape to match grid size
            P = shiftdim( reshape( P, [size(P,1) obj.stimulus_grid_size] ), 1 );
            
        end
        function M = compute_source_tuning( obj )
            
            %get which sources to compute
            currentstate = obj.state(end);
            src_idx = find( currentstate.source_selection );
            
            %get stimulus grid and mask invalid elements
            stimgrid = obj.stimulus_grid_expanded;
            if ~isempty(currentstate.stimulus_grid_validity)
                stimgrid( currentstate.stimulus_grid_validity,:) = NaN;
            end
            
            %get spike stimulus and response
            sp_stimulus = get_spike_stimulus_cache(obj);
            sp_stimulus = sp_stimulus( src_idx );
            
            sp_response = get_spike_response_cache(obj);
            sp_response = sp_response( src_idx );
            
            %get distance matrices
            dist_lut = get_distance_cache(obj);
            
            nsrc = numel(src_idx);
            
            %pre-allocate arrays
            M = cell( nsrc, 1 );
            
            %get stimulus marginal
            stim_marginal = obj.get_stimulus_marginal_cache();
            training_duration = obj.training_duration;
            
            %compute rates and marginal rates for all sources
            if obj.parallel && matlabpool('size')>1
                
                parfor src = 1:numel(src_idx)
                    
                    M{src} = compute_source_tuning(src_idx(src), sp_stimulus{src}, sp_response{src}, stimgrid, currentstate, dist_lut, stim_marginal, training_duration);
                    
                end
                
            else
                
                for src = 1:numel(src_idx)
                    
                    M{src} = compute_source_tuning(src_idx(src), sp_stimulus{src}, sp_response{src}, stimgrid, currentstate, dist_lut, stim_marginal, training_duration);
                    
                end
                
            end
               

            %reshape to match grid size
            M = vertcat( M{:} );
            M = shiftdim( reshape( M, [size(M,1) obj.stimulus_grid_size] ), 1 );
            
        end
        function s = compute_performance(obj,true_stim,estimate,use_marginal)
            
            if nargin<3
                err = MException( 'kde_decoder:compute_performance:invalidArguments', 'Need at least two input arguments');
                throw(err);
            end
            
            %check if we should use the marginal of the posterior to find
            %the posterior mode
            if nargin<4 || isempty(use_marginal)
                use_marginal = false;
            else
                use_marginal = isequal( use_marginal, true );
            end
            
            %find the posterior mode
            [estimate_mode{1:obj.ndim_stimulus}] = posterior_mode( estimate, obj.ndim_stimulus, 'marginal', use_marginal );
            estimate_mode = cellfun( @(x,y) reshape(x(y),numel(y),1), obj.stimulus_grid, estimate_mode, 'UniformOutput', false );
            estimate_mode = horzcat( estimate_mode{:} );
            
            %compute error per dimension
            estimate_error = zeros(size(estimate_mode));
            for k=1:obj.ndim_stimulus
                if ~isempty( obj.distance_lut{k} )
                    %use distance matrix
                    estimate_error(:,k) = obj.distance_lut{k}( sub2ind( size(obj.distance_lut{k}), true_stim(:,k)+1, estimate_mode(:,k)+1 ) );
                elseif strcmp( obj.variable_types{ obj.stimulus_variable_type(k) }, 'circular' )
                    %use circular difference
                    estimate_error(:,k) = circ_diff( true_stim(:,k), estimate_mode(:,k) );
                elseif strcmp( obj.variable_types{ obj.stimulus_variable_type(k) }, 'categorical' )
                    %use binary difference
                    estimate_error(:,k) = true_stim(:,k)~=estimate_mode(:,k);
                else
                    %use algebraic difference
                    estimate_error(:,k) = abs( true_stim(:,k) - estimate_mode(:,k) );
                end
            end
            
            %compute summary error
            %use mean for categorical variables (result is fraction correct)
            %use median for other variable types
            idx = strcmp( obj.variable_types( obj.stimulus_variable_type ), 'categorical' );
            summary_error = NaN(1,obj.ndim_stimulus);
            summary_error(1, idx ) = mean( estimate_error(:,idx) );
            summary_error(1,~idx ) = median( estimate_error(:,~idx) );
            %compute bootstrap confidence intervals for summary error
            summary_error_ci(:, idx) = bootci( 1000, @mean,   estimate_error(:, idx) );
            summary_error_ci(:,~idx) = bootci( 1000, @median, estimate_error(:,~idx) );
            
            %pre-allocate matrices
            conf = cell(1,obj.ndim_stimulus);
            muinfo = zeros(1,obj.ndim_stimulus);
            ientro = zeros(1,obj.ndim_stimulus);
            muinfo_unbiased = zeros(1,obj.ndim_stimulus);
            ientro_unbiased = zeros(1,obj.ndim_stimulus);
            
            gridsize = obj.stimulus_grid_size;
            
            %compute confusion matrix, mutual information and entropy for
            %all dimensions
            for k=1:obj.ndim_stimulus
                %compute indices into grid for true and estimated stimulus values
                true_stim(:,k) = reshape( nearestpoint( true_stim(:,k), obj.stimulus_grid{k}(:) ), size(true_stim,1), 1 );
                estimate_mode(:,k) = reshape( nearestpoint( estimate_mode(:,k), obj.stimulus_grid{k}(:) ), size(estimate_mode,1), 1 );
                %compute confusion matrix (no normalization)
                conf{k} = accumarray( [true_stim(:,k) estimate_mode(:,k)], 1, [gridsize(k) gridsize(k)]);
                %compute mutual information
                muinfo(1,k) = mutualinfo( conf{k} );
                %compute entropy of true stimulus
                ientro(1,k) = ientropy( sum( conf{k}, 2 ) );
                %perform jackknife bias correction for mutual information
                %and entropy
                jj = jackknife( @(x,y) local_jackknife(x,y,gridsize(k)), true_stim(:,k),  estimate_mode(:,k) );
                unbiased = size(true_stim,1).*[muinfo(1,k) ientro(1,k)] - (size(true_stim,1)-1).*mean(jj);
                muinfo_unbiased(1,k) = unbiased(1);
                ientro_unbiased(1,k) = unbiased(2);
            end
            
            %compute confusion matrix for all dimensions combined
            conf_all = accumarray( [true_stim estimate_mode], 1, [gridsize gridsize]);
            
            %construct output
            s = struct( 'estimate_type', onoff(use_marginal, {'marginal', 'max a posteriori'}), 'estimation_error', estimate_error, 'summary_error', summary_error, 'summary_error_ci', summary_error_ci, 'mutual_info', muinfo, 'mutual_info_unbiased', muinfo_unbiased, 'entropy', ientro, 'entropy_unbiased', ientro_unbiased, 'mutual_info_unbiased_normalized', muinfo_unbiased./ientro_unbiased, 'confusion', {conf}, 'confusion_all', conf_all );
            
            %inline function for jackknifing
            function output = local_jackknife(jx,jy,gg)
                cc = accumarray( [jx jy], 1, [gg gg] );
                output = [ mutualinfo( cc ) ientropy( sum(cc,2) ) ];
            end
            
            
        end
        
    end
    
    methods
        
        %PUSH/POP STATE
        function push_state(obj)
            obj.state(end+1) = obj.state(end);
        end
        function pop_state(obj)
            if numel(obj.state)>1
                obj.state(end) = [];
                obj.flag_distance_cache = true;
                obj.flag_stimulus_cache = true;
                obj.flag_response_cache = true;
                obj.flag_index_cache = true;
                obj.flag_response_filter_cache = true;
                obj.flag_marginal_cache = true;
            end
        end
        
        %GET (DEPENDENT PROPS)
        function val = get.ndim_stimulus(obj)
            val = size(obj.training_stimulus,2);
        end
        function val = get.ndim_response(obj)
            val = cellfun( @(x) size(x,2), obj.spike_response );
        end
        function val = get.nsources(obj)
            val = numel(obj.spike_stimulus);
        end
        function val = get.nspikes(obj)
            val = cellfun( @(x) size(x,1), obj.spike_stimulus );
        end
        function val = get.mean_rate(obj)
            val = obj.nspikes ./ obj.training_duration;
        end
        function val = get.stimulus_grid_size(obj)
            current_state = numel(obj.state);
            val = cellfun('prodofsize',obj.state(current_state).stimulus_grid);
        end
        function val = get.current_state(obj)
            val = obj.state(end);
        end
        function val = get.training_duration(obj)
            val = sum( diff( obj.state(end).encoding_segments, [], 2) );
        end
        function val = get.stimulus_marginal(obj)
            update_marginal_cache(obj);
            val = obj.marginal_cache.stimulus;
        end
        
        %GET/SET
        function val=get.rate_modulation(obj)
            val = obj.state(end).rate_modulation;
        end
        function set.rate_modulation(obj,val)
            if ~isnumeric(val) || ndims(val)~=2 || ( ~isscalar(val) && numel(val)~=obj.nsources ) || any(val<=0)
                error('kde_decoder:setrate_modulation:invalidValue', 'Invalid value')
            end
            obj.state(end).rate_modulation = val(:).*ones(obj.nsources,1);
        end
        
        function val=get.rate_offset(obj)
            val = obj.state(end).rate_offset;
        end
        function set.rate_offset(obj,val)
            if ~isnumeric(val) || ~isscalar(val) || val<0
                error('kde_decoder:setrate_offset:invalidValue', 'Invalid value')
            end
            obj.state(end).rate_offset = val;
        end
        
        function set.parallel(obj,val)
            obj.parallel = isequal( val, true );
        end
        
        function val=get.response_randomization(obj)
            val = obj.state(end).response_randomization;
        end
        function set.response_randomization(obj,val)
            if isa(val, 'function_handle')
                obj.state(end).response_randomization = val;
            elseif ~isscalar(val) || (~isnumeric(val) && ~islogical(val))
                err = MException('kde_decoder:set_response_randomization:invalidArgument','Invalid value');
                throw(err);
            else
                obj.state(end).response_randomization = (val~=0);
            end
        end
        
        function val=get.response_transformation(obj)
            val = obj.state(end).response_transformation;
        end
        function set.response_transformation(obj,val)
            if isempty(val)
                val = @(x,src) x;
            elseif ~isa(val,'function_handle')
                err = MException('kde_decoder:set_response_randomization:invalidArgument','Invalid value');
                throw(err);
            end
            obj.state(end).response_transformation = val;
            obj.flag_response_cache = true;
        end
        
        function val=get.response_filter(obj)
            val = obj.state(end).response_filter;
        end
        function set.response_filter(obj,val)
            if isempty(val)
                val = @(x,src) true(size(x,1),1);
            elseif ~isa(val,'function_handle')
                err = MException('kde_decoder:set_response_filter:invalidArgument','Invalid value');
                throw(err);
            end
            obj.state(end).response_filter = val;
            obj.flag_stimulus_cache = true;
            obj.flag_response_cache = true;
            obj.flag_response_filter_cache = true;
            obj.flag_marginal_cache = true;
        end
        
        function val=get.response_filter_post(obj)
            val = obj.state(end).response_filter_post;
        end
        function set.response_filter_post(obj,val)
            if isempty(val)
                val = @(x,src) true(size(x,1),1);
            elseif ~isa(val,'function_handle')
                err = MException('kde_decoder:set_response_filter:invalidArgument','Invalid value');
                throw(err);
            end
            obj.state(end).response_filter_post = val;
        end
        
        function val=get.stimulus_kernel(obj)
            val = obj.state(end).stimulus_kernel;
        end
        function set.stimulus_kernel(obj,val)
            if nargin<2 || isempty(val)
                return
            elseif ischar( val ) || (iscellstr(val) && numel(val)==obj.ndim_stimulus)
                val = obj.validate_kernels( val );
                val = ones(1,obj.ndim_stimulus).*val(:)';
                val = kde_decoder.cross_check_kernel( val, obj.stimulus_variable_type );
                obj.state(end).stimulus_kernel = ones(1,obj.ndim_stimulus).*val(:)';
            else
                err = MException('kde_decoder:set_stimulus_kernel:invalidArgument','Kernel should be specified as a string or cell array of strings');
                throw(err);
            end
            
            obj.flag_distance_cache = true;
            obj.flag_stimulus_cache = true;
            obj.flag_marginal_cache = true;
            
        end
        
        function val=get.stimulus_bandwidth(obj)
            val = obj.state(end).stimulus_bandwidth;
        end
        function set.stimulus_bandwidth( obj, w )
            if nargin<2 || isempty(w)
                return
            elseif ~isnumeric(w) || ~isvector(w) || (~isscalar(w) && numel(w)~=obj.ndim_stimulus) || any(w<=0)
                err = MException('kde_decoder:set_stimulus_bandwidth:invalidArgument','Invalid stimulus kernel bandwidth');
                throw(err);
            else
                w = kde_decoder.cross_check_bandwidth(ones(1,obj.ndim_stimulus).*w(:)', obj.stimulus_variable_type );
                obj.state(end).stimulus_bandwidth = w;
            end
            
            obj.flag_distance_cache = true;
            obj.flag_stimulus_cache = true;
            obj.flag_marginal_cache = true;

        end
        
        function val=get.response_kernel(obj)
            val = obj.state(end).response_kernel;
        end
        function set.response_kernel(obj,val)
            obj.set_response_kernel( val );
        end
        function set_response_kernel( obj, arg1, arg2 )
           
            if nargin<2
                return
            elseif nargin<3
                idx = (1:obj.nsources)';
                k = arg1;
            else
                idx = arg1;
                k = arg2;
            end
            
            if isempty(idx) || ~isnumeric(idx) || ~isvector(idx) || any( idx<1 | idx>obj.nsources )
                err = MException('kde_decoder:set_response_kernel:invalidArgument','Invalid source indices');
                throw(err);
            end
            
            idx = unique(idx);
            
            if ischar(k) || isempty(k)
                k = obj.validate_kernels( k );
                for j=1:numel(idx)
                    obj.state(end).response_kernel{idx(j),1} = kde_decoder.cross_check_kernel( ones(1,obj.ndim_response(idx(j))).*k, obj.response_variable_type{idx(j)});
                end
            elseif iscellstr(k) && isequal( size(k), [1 obj.ndim_response(idx(1))]) && isscalar( unique( obj.ndim_response(idx) ) )
                k = obj.validate_kernels( k );
                for j=1:numel(idx)
                    obj.state(end).response_kernel{idx(j),1} = kde_decoder.cross_check_kernel( k, obj.response_variable_type{idx(j)} );
                end
            elseif iscellstr(k) && isequal( size(k), [numel(idx) obj.ndim_response(idx(1))]) && isscalar( unique( obj.ndim_response(idx) ) )
                k = obj.validate_kernels( k );
                for j=1:numel(idx)
                    obj.state(end).response_kernel{idx(j),1} = kde_decoder.cross_check_kernel( k(j,:), obj.response_variable_type{idx(j)} );
                end
            elseif iscell(k) && isequal( size(k), [numel(idx) 1] )
                for j=1:numel(idx)
                    tmp = obj.validate_kernels( k{j} );
                    if ~isscalar(tmp) && numel(tmp)~=obj.ndim_response(idx(j))
                        err = MException('kde_decoder:set_response_kernel:invalidArgument','Invalid response kernel');
                        throw(err);
                    end
                    obj.state(end).response_kernels{ idx(j),1 } = kde_decoder.cross_check_kernel( ones(1,obj.ndim_response(idx(j))).*tmp(:)', obj.response_variable_type{idx(j)} );
                end
            else
                err = MException('kde_decoder:set_response_kernel:invalidArgument','Invalid response kernel');
                throw(err)
            end
               
            obj.flag_response_cache = true;
            
        end
        
        function val=get.response_bandwidth(obj)
            val = obj.state(end).response_bandwidth;
        end
        function set.response_bandwidth(obj,val)
            obj.set_response_bandwidth( val );
        end
        function set_response_bandwidth( obj, arg1, arg2 )
            if nargin<2
                return
            elseif nargin<3
                idx = (1:obj.nsources)';
                w = arg1;
            else
                idx = arg1;
                w = arg2;
            end
            
            if isempty(idx) || ~isnumeric(idx) || ~isvector(idx) || any( idx<1 | idx>obj.nsources )
                err = MException('kde_decoder:set_response_bandwidth:invalidArgument','Invalid source indices');
                throw(err);
            end
            
            idx = unique(idx);
            
            D = obj.ndim_response(idx);
            uD = isscalar( unique( D ) );
            
            if isempty(w) || (isnumeric(w) && ndims(w)==2 && (size(w,2)==1 || (size(w,2)==D(1) && uD)) && (size(w,1)==1 || size(w,1)==numel(idx)))
                if isempty(w)
                    w = ones(numel(idx),D(1));
                else
                    w = bsxfun(@times, ones(numel(idx),D(1)), w );
                end
                for j=1:numel(idx)
                    obj.state(end).response_bandwidth{idx(j),1} = kde_decoder.cross_check_bandwidth( ones(1,D(j)).*w(j,:), obj.response_variable_type{idx(j)});
                end
            elseif iscell(w) && numel(w)==numel(idx)
                for j=1:numel(idx)
                    if isnumeric(w{j}) && ( isscalar(w{j}) || numel(w)==D(j) )
                        obj.state(end).response_bandwidth{idx(j),1} = kde_decoder.cross_check_bandwidth( ones(1,D(j)).*w{j}(:)', obj.response_variable_type{idx(j)});
                    else
                        err = MException('kde_decoder:set_response_bandwidth:invalidArgument','Invalid bandwidth');
                        throw(err);
                    end
                end
            else
                err = MException('kde_decoder:set_response_bandwidth:invalidArgument','Invalid bandwidth');
                throw(err);
            end
            
            obj.flag_response_cache = true;
        end
        
        function val=get.response_selection(obj)
            val=obj.state(end).response_selection;
        end
        function set.response_selection(obj,val)
            obj.set_response_selection( val );
        end
        function set_response_selection( obj, arg1, arg2 )
            if nargin<2
                return
            elseif nargin<3
                idx = (1:obj.nsources)';
                w = arg1;
            else
                idx = arg1;
                w = arg2;
            end
            
            if isempty(idx) || ~isnumeric(idx) || ~isvector(idx) || any( idx<1 | idx>obj.nsources )
                err = MException('kde_decoder:set_response_bandwidth:invalidArgument','Invalid source indices');
                throw(err);
            end
            
            idx = unique(idx);
            
            D = obj.ndim_response(idx);
            uD = isscalar( unique( D ) );
            
            if isempty(w) || (isnumeric(w) || islogical(w)) && ndims(w)==2 && (size(w,2)==1 || (size(w,2)==D(1) && uD)) && (size(w,1)==1 || size(w,1)==numel(idx))
                if isempty(w)
                    w = ones(numel(idx),D(1));
                else
                    w = bsxfun(@times, ones(numel(idx),D(1)), w );
                end
                for j=1:numel(idx)
                    obj.state(end).response_selection{idx(j),1} = true(1,D(j)) & (w(j,:)~=0);
                end
            elseif iscell(w) && numel(w)==numel(idx)
                for j=1:numel(idx)
                    if (islogical(w{j}) || isnumeric(w{j})) && ( isscalar(w{j}) || numel(w{j})==D(j) )
                        obj.state(end).response_selection{idx(j),1} = true(1,D(j)) & (w{j}(:)'~=0);
                    else
                        err = MException('kde_decoder:set_response_bandwidth:invalidArgument','Invalid response selection');
                        throw(err);
                    end
                end
            else
                err = MException('kde_decoder:set_response_bandwidth:invalidArgument','Invalid response selection');
                throw(err);
            end
            
            obj.flag_response_cache = true;
        end
        function r = set_random_response_selection(obj,K,M)
            
            nd = obj.ndim_response;
            
            if nargin<3 || isempty(M)
                M = 1:min(nd);
            elseif ~isnumeric(M) || ~isvector(M) || any(M<1 | M>min(nd))
                error('kde_decoder:set_random_response_selection', 'Invalid response dimension indices' );
            end
            
            if nargin<2 || isempty(K)
                K = 1;
            elseif ~isnumeric(K) || ~isscalar(K) || K<=0 || K>numel(M)
                error('kde_decoder:set_random_response_selection', 'Invalid number of responses' )
            end
                
            nsrc = obj.nsources;
            r = cell(nsrc,1);
            
            for s=1:nsrc
                
                r{s} = zeros(1,nd(s));
                r{s}( 1, randsample( M, K, false ) ) = 1;
                
            end
            
            obj.set_response_selection( r );
            
        end
        
        function val=get.stimulus_grid(obj)
            val = obj.state(end).stimulus_grid;
        end
        function set.stimulus_grid( obj, val )

            if nargin<2
                return
            elseif isempty(val)
                obj.state(end).stimulus_grid = cell(1,obj.ndim_stimulus);
                obj.stimulus_grid_expanded = zeros(0,obj.ndim_stimulus);
                return
            end
            
            if isnumeric(val) && isvector(val) && (isscalar(val) || numel(val)==obj.ndim_stimulus) && all(val>0)
                tmp = cell(1,obj.ndim_stimulus);
                stimrange = [ min(obj.training_stimulus) ; max(obj.training_stimulus) ];
                val = bsxfun( @times, val(:), ones(obj.ndim_stimulus,1) );
                for k=1:obj.ndim_stimulus
                    tmp{k} = linspace( stimrange(1,k), stimrange(2,k), val(k) );
                end
                val = tmp;
            elseif ~iscell(val) || numel(val)~=obj.ndim_stimulus || ~all( cellfun( @(x) isnumeric(x)&&isvector(x), val(:) ) )
                err = MException('kde_decoder:set_stimulus_grid:invalidValue', ...
                                 'Grid can be empty, a vector of grid sizes or a cell array of grids');
                throw(err);
            end
            
            ni = cellfun( @(x) size(x,1), obj.distance_lut(:)' );
            idx = ni>0;
            %round to nearest integer
            val(idx | obj.stimulus_variable_type==3) = cellfun( @(x) round(x), val(idx | obj.stimulus_variable_type==3), 'UniformOutput', false );

            %check validity of indices
            for k=1:obj.ndim_stimulus
                if (idx(k)) && any( val{k}>=ni(k) | val{k}<0 )
                    err = MException('kde_decoder:set_stimulus_grid:invalidValue', 'Index out of range for stimulus dimensions with a distance lookup table');
                    throw(err);
                end
            end
            
            obj.state(end).stimulus_grid = val;
            
            %create grid
            [g{1:obj.ndim_stimulus}] = ndgrid( val{:}, 1 );
            g = cellfun( @(x) x(:), g, 'UniformOutput', false );
            g = cat(2, g{:} );
            obj.stimulus_grid_expanded = g;
            
            obj.flag_marginal_cache = true;
            %obj.update_marginals();
            
        end
        
        function val=get.stimulus_grid_validity(obj)
            val = obj.state(end).stimulus_grid_validity;
        end
        function set.stimulus_grid_validity(obj,val)
            if ~islogical(val) && ~isempty(val)
                err = MException('kde_decoder:set_stimulus_grid_validity:invalidValue', 'Invalid value');
                throw(err);
            end
            
            obj.state(end).stimulus_grid_validity = val;
           
            obj.flag_marginal_cache = true;
            
        end
        
        function val=get.source_selection(obj)
            val = obj.state(end).source_selection;
        end
        function set.source_selection(obj,val)
            if isempty(val)
                obj.state(end).source_selection = true(obj.nsources,1);
            elseif isscalar(val)
                obj.state(end).source_selection = true(obj.nsources,1) & isequal(val,true);
            elseif (~isnumeric(val) && ~islogical(val)) || ~isvector(val) || numel(val)~=obj.nsources
                err = MException('kde_decoder:set_source_selection:invalidArgument','Invalid value');
                throw(err);
            else
                obj.state(end).source_selection = logical(val(:));
            end
        end
        function select_sources( obj, idx )
            if nargin<2 || isempty(idx)
                return
            elseif ~isnumeric(idx) || ~isvector(idx) || any( idx<1 | idx>obj.nsources )
                err = MException('kde_decoder:select_sources:invalidArgument','Invalid source indices');
                throw(err);
            else
                obj.state(end).source_selection(:) = false;
                obj.state(end).source_selection( unique( round(idx(:)) ) ) = true;
            end
        end
        function select_all_sources(obj)
            obj.state(end).source_selection(:) = true;
        end
        
        function val = get.encoding_segments(obj)
            val = obj.state(end).encoding_segments;
        end
        function set.encoding_segments(obj,val)
            if ~isseg(val)
                err = MException('kde_decoder:setencoding_segments:invalidArgument','Invalid value');
                throw(err);
            end
            obj.state(end).encoding_segments = seg_and( val, obj.training_time([1 end])' );
            obj.flag_stimulus_cache = true;
            obj.flag_response_cache = true;
            obj.flag_index_cache = true;
            obj.flag_marginal_cache = true;
        end
         
    end
    
    methods (Access=protected, Hidden=true)
        %CACHING FUNCTIONS
        function update_distance_cache(obj)
            if obj.flag_distance_cache && ...
                    ( ~isequal(obj.distance_cache.state.stimulus_kernel, obj.state(end).stimulus_kernel ) || ...
                    ~isequal( obj.distance_cache.state.stimulus_bandwidth, obj.state(end).stimulus_bandwidth ) )
                
                ni = cellfun( @(x) size(x,1), obj.distance_lut(:)' );
                                
                obj.distance_cache.data = cell(1,obj.ndim_stimulus);
                
                for k=1:numel(obj.ndim_stimulus)
                   if ni(k)~=0 && obj.state(end).stimulus_kernel(k)~=3
                        %distance matrix specified and kernel is not von Mises
                        %divide by bandwidth
                        obj.distance_cache.data{k} = obj.distance_lut{k}./obj.state(end).stimulus_bandwidth(k);
                    else
                        %no distance matrix or von Mises kernel: copy
                        obj.distance_cache.data{k} = obj.distance_lut{k};
                    end
                end
                
                obj.distance_cache.state.stimulus_kernel = obj.state(end).stimulus_kernel;
                obj.distance_cache.state.stimulus_bandwidth = obj.state(end).stimulus_bandwidth;
                
            end
            obj.flag_distance_cache = false;
        end
        function val = get_distance_cache(obj)
            update_distance_cache(obj)
            val = obj.distance_cache.data;
        end
        
        function update_index_cache(obj)
            if obj.flag_index_cache && ...
                    ( ~isequal( obj.index_cache.state.encoding_segments, obj.state(end).encoding_segments ) )
               
                obj.index_cache.training = fast_inseg( obj.state(end).encoding_segments, obj.training_time );
                obj.index_cache.spike = cellfun( @(x) fast_inseg( obj.state(end).encoding_segments, x), obj.spike_time, 'UniformOutput', false );
            
                obj.index_cache.state.encoding_segments = obj.state(end).encoding_segments;
            end
            obj.flag_index_cache = false;
        end
        function val = get_training_index_cache(obj)
            update_index_cache(obj);
            val = obj.index_cache.training;
        end
        function val = get_spike_index_cache(obj)
            update_index_cache(obj);
            val = obj.index_cache.spike;
        end
        
        function update_response_filter_cache(obj)
            if obj.flag_response_filter_cache && ...
                    ( ~isequal( obj.state(end).response_filter, obj.response_filter_cache.state.response_filter ) )
                
                src_idx = num2cell( cumsum(ones(size(obj.spike_response))) );
                
                obj.response_filter_cache.data = cellfun( @(x,src) obj.state(end).response_filter(x,src), obj.spike_response, src_idx, 'UniformOutput', false );
                
                obj.response_filter_cache.state.response_filter = obj.state(end).response_filter;
                
            end
            obj.flag_response_filter_cache = false;
        end
        function val = get_response_filter_cache(obj)
            update_response_filter_cache(obj);
            val = obj.response_filter_cache.data;
        end
        
        function update_spike_stimulus_cache(obj)
            if obj.flag_stimulus_cache && ...
                    ( ~isequal( obj.spike_stimulus_cache.state.stimulus_kernel, obj.state(end).stimulus_kernel ) || ...
                    ~isequal(obj.spike_stimulus_cache.state.stimulus_bandwidth, obj.state(end).stimulus_bandwidth ) || ...
                    ~isequal( obj.spike_stimulus_cache.state.encoding_segments, obj.state(end).encoding_segments ) || ...
                    ~isequal( obj.state(end).response_filter, obj.spike_stimulus_cache.state.response_filter ) )
                
                obj.spike_stimulus_cache.data = cellfun( @(x,y,z) x(y&z,:), obj.spike_stimulus, get_spike_index_cache(obj), get_response_filter_cache(obj), 'UniformOutput', false );
            
                stim_k = obj.state(end).stimulus_kernel;
                dist_lut = obj.get_distance_cache();
                ni = cellfun( @(x) size(x,1), dist_lut(:)' );
                idx = stim_k~=3 & ni==0;
                if sum(idx)>0
                    for k=1:numel(obj.spike_stimulus_cache.data)
                        obj.spike_stimulus_cache.data{k}(:,idx) = bsxfun( @rdivide, obj.spike_stimulus_cache.data{k}(:,idx), obj.state(end).stimulus_bandwidth(idx) );
                    end
                    %obj.spike_stimulus_cache.data = cellfun( @(x) bsxfun( @rdivide, x(:,idx), obj.state(end).stimulus_bandwidth(idx) ), obj.spike_stimulus_cache.data, 'UniformOutput', false);
                end
                
                obj.spike_stimulus_cache.state.stimulus_kernel = obj.state(end).stimulus_kernel;
                obj.spike_stimulus_cache.state.stimulus_bandwidth = obj.state(end).stimulus_bandwidth;
                obj.spike_stimulus_cache.state.response_filter = obj.state(end).response_filter;
                obj.spike_stimulus_cache.state.encoding_segments = obj.state(end).encoding_segments;
                
            end
            obj.flag_stimulus_cache = false;
        end 
        function val = get_spike_stimulus_cache(obj)
            update_spike_stimulus_cache(obj);
            val = obj.spike_stimulus_cache.data;
        end
            
        function update_spike_response_cache(obj)
            if obj.flag_response_cache && ...
                    ( ~isequal( obj.spike_response_cache.state.response_kernel, obj.state(end).response_kernel ) || ...
                    ~isequal(obj.spike_response_cache.state.response_bandwidth, obj.state(end).response_bandwidth ) || ...
                    ~isequal( obj.spike_response_cache.state.encoding_segments, obj.state(end).encoding_segments ) || ...
                    ~isequal( obj.state(end).response_filter, obj.spike_response_cache.state.response_filter ) || ...
                    ~isequal( obj.spike_response_cache.state.response_transformation, obj.state(end).response_transformation ) ) %|| ...
                    %~isequal( obj.spike_response_cache.state.response_selection, obj.state(end).response_selection ) )
               
                src_idx = num2cell( cumsum(ones(size(obj.spike_response))) );
                
                obj.spike_response_cache.data = cellfun( @(x,y,z,src) obj.state(end).response_transformation(x(y&z,:), src), obj.spike_response, obj.get_spike_index_cache(), obj.get_response_filter_cache(), src_idx, 'UniformOutput', false );
                %obj.spike_response_cache.data = cellfun( @(x,y) x(:,y), obj.spike_response_cache.data, obj.state(end).response_selection, 'UniformOutput', false );
                %resp_k = cellfun( @(x,y) x(:,y), obj.state(end).response_kernel, obj.state(end).response_selection, 'UniformOutput', false );
                %resp_w = cellfun( @(x,y) x(:,y), obj.state(end).response_bandwidth, obj.state(end).response_selection, 'UniformOutput', false );
                resp_k = obj.state(end).response_kernel;
                resp_w = obj.state(end).response_bandwidth;
                obj.spike_response_cache.data = cellfun( @(x,y,z) bsxfun( @rdivide, x(:,y~=3), z(y~=3) ), obj.spike_response_cache.data, resp_k, resp_w, 'UniformOutput', false );
                
                obj.spike_response_cache.state.response_kernel = obj.state(end).response_kernel;
                obj.spike_response_cache.state.response_bandwidth = obj.state(end).response_bandwidth;
                obj.spike_response_cache.state.response_transformation = obj.state(end).response_transformation;
                %obj.spike_response_cache.state.response_selection = obj.state(end).response_selection;
                obj.spike_response_cache.state.response_filter = obj.state(end).response_filter;
                obj.spike_response_cache.state.encoding_segments = obj.state(end).encoding_segments;
                
            end
            obj.flag_response_cache = false;
        end
        function val = get_spike_response_cache(obj)
            update_spike_response_cache(obj);
            val = obj.spike_response_cache.data;
        end
        
        function update_marginal_cache(obj)
            if obj.flag_marginal_cache
                
                obj.marginal_cache.stimulus = obj.compute_stimulus_marginal();
                %obj.marginal_cache.spike_stimulus = obj.compute_spike_stimulus_marginal();
                
                obj.marginal_cache.state.stimulus_kernel = obj.state(end).stimulus_kernel;
                obj.marginal_cache.state.stimulus_bandwidth = obj.state(end).stimulus_bandwidth;
            end
            obj.flag_marginal_cache = false;
        end
        function val = get_stimulus_marginal_cache(obj)
            update_marginal_cache(obj)
            val = obj.marginal_cache.stimulus;
        end
%         function val = get_spike_stimulus_marginal_cache(obj)
%             update_marginal_cache(obj)
%             val = obj.marginal_cache.spike_stimulus;
%         end
        
    end
    
    methods (Access=protected, Hidden=true)
        %COMPUTE MARGINALS
        function m=compute_marginal(obj,x)
            
            stim_grid = obj.stimulus_grid_expanded;
            if ~isempty(obj.state(end).stimulus_grid_validity)
                stim_grid(obj.state(end).stimulus_grid_validity, :) = NaN;
            end
            valid_grid = ~isnan( stim_grid(:,1) );
            
            stim_bandwidth = obj.state(end).stimulus_bandwidth;
            stim_kernel = obj.state(end).stimulus_kernel;
            dist_lut = get_distance_cache(obj);
            ni = cellfun( @(x) size(x,1), dist_lut(:)' );
            idx = ni==0 & stim_kernel~=3;
            if sum(idx)>0
                stim_grid( :, idx ) = bsxfun( @rdivide, stim_grid(:, idx ), stim_bandwidth(idx) );
            end
            
            f = kde_decoder.get_func( obj.state(end).stimulus_kernel, [] );
            m = zeros( [1 size(stim_grid,1)] );
            m(~valid_grid) = NaN;
            m(valid_grid) = exp( f( x, stim_grid(valid_grid,:), obj.state(end).stimulus_kernel, obj.state(end).stimulus_bandwidth, [], [], zeros(0,1), zeros(1,0), zeros(sum(valid_grid),1), get_distance_cache(obj) ) );
            m = m./nansum(m(:));
            
        end
        function m=compute_stimulus_marginal(obj)

            dist_lut = obj.get_distance_cache();
            ni = cellfun( @(x) size(x,1), dist_lut(:)' );
            idx = ni==0 & obj.state(end).stimulus_kernel~=3;
            if sum(idx)>0
                m = obj.training_stimulus( get_training_index_cache(obj), : );
                m(:,idx) = bsxfun( @rdivide, m(:,idx), obj.state(end).stimulus_bandwidth( idx ) );
            else
                m = obj.training_stimulus( get_training_index_cache(obj), : );
            end
            m = obj.compute_marginal( m );
        end

    end
    
    methods (Static=true, Hidden=true)
       
        function k = validate_kernels(k)
            if nargin<1 || isempty(k)
                k = 1;
            elseif ischar(k) || iscellstr(k)
                [~,k] = ismember( k, kde_decoder.kernel_types );
                if any(k(:)==0)
                    err = MException('kde_decoder:validate_kernels:invalidValue', ...
                                     'Unknown kernel specified');
                    throw(err);
                end
            elseif ~isnumeric(k) || any( k(:)<1 | k(:)>numel(kde_decoder.kernel_types) )
                ktypes = kde_decoder.kernel_types;
                err = MException('kde_decoder:validate_kernels:invalidValue', ...
                                 ['Kernel type can be one of: ' sprintf( '''%s'' ', ktypes{:} ) ] );
                throw(err);
                
            end
            k = round(k);
        end
        
        function k = validate_vartypes(k)
            if nargin<1 || isempty(k)
                k = 1;
            elseif ischar(k) || iscellstr(k)
                [~,k] = ismember( k, kde_decoder.variable_types );
                if any(k(:)==0)
                    err = MException('kde_decoder:validate_vartypes:invalidValue', ...
                                     'Unknown variable type specified' );
                    throw(err);
                end
            elseif ~isnumeric(k) || any( k(:)<1 | k(:)>numel(kde_decoder.variable_types) )
                vtypes = kde_decoder.variable_types;
                err = MException('kde_decoder:validate_vartypes:invalidValue', ...
                                 ['Variable type can be one of: ' sprintf( '''%s'' ', vtypes{:} ) ] );
                throw(err);
            end
            k = round(k);
        end
        
        function k = cross_check_kernel(k,v)
            if nargin<2 || ~isnumeric(k) || ~isnumeric(v) || ~isequal( size(k), size(v) )
                err = MException('kde_decoder:cross_check_kernel:invalidArgument', 'Invalid arguments');
                throw(err);
            end
            
            idx = strcmp( kde_decoder.variable_types(v), 'linear' );
            if ~all( ismember( kde_decoder.kernel_types( k(idx) ), { 'gaussian', 'epanechnikov', 'kronecker' } ) )
                warning('kde_decoder:cross_check_kernel:invalidKernel', 'Only gaussian, epanechnikov and kronecker delta kernels are supported for linear variables. Kernel type set to gaussian.');
                k(idx) = find( strcmp( kde_decoder.kernel_types, 'gaussian' ) );
            end
            
            idx = strcmp( kde_decoder.variable_types(v), 'circular' );
            if ~all( ismember( kde_decoder.kernel_types( k(idx) ), { 'vonmises' } ) )
                warning('kde_decoder:cross_check_kernel:invalidKernel', 'Only von Mises kernel is supported for circular variables. Kernel type set to von Mises.');
                 k(idx) = find( strcmp( kde_decoder.kernel_types, 'vonmises' ) );
            end
            
            idx = strcmp( kde_decoder.variable_types(v), 'categorical' );
            if ~all( ismember( kde_decoder.kernel_types( k(idx) ), { 'kronecker' } ) )
                warning('kde_decoder:cross_check_kernel:invalidKernel', 'Only kronecker delta kernel is supported for categorical variables. Kernel type set to kronecker delta');
                k(idx) = find( strcmp( kde_decoder.kernel_types, 'kronecker' ) );
            end
            
        end
            
        function w = cross_check_bandwidth(w,v)
            if nargin<2 || ~isnumeric(w) || ~isnumeric(v) || ~isequal( size(w), size(v) )
                err = MException('kde_decoder:cross_check_bandwidth:invalidArgument', 'Invalid arguments');
                throw(err);
            end
            
            idx = strcmp( kde_decoder.variable_types(v), 'categorical' );
            w(idx) = 0.5;
            
        end
        
        function [f,s] = get_func( stim_k, resp_k )
            
            kernels = unique( [stim_k(:);resp_k(:)] );
            
            if numel(kernels)>1 || kernels==3
                s = 'kde_decode_general';
                f = @(stim, stim_grid, stim_k, stim_w, resp, resp_k, resp_w, test_resp, ofs, dist_lut, varargin) kde_decode_general( stim, stim_grid, stim_k-1, stim_w, resp, resp_k-1, resp_w, test_resp, ofs, dist_lut, varargin{:} );
            elseif kernels==1 %gaussian
                s = 'kde_decode_gauss';
                f = @(stim, stim_grid, stim_k, stim_w, resp, resp_k, resp_w, test_resp, ofs, dist_lut, varargin) kde_decode_gauss( stim, stim_grid, resp, test_resp, ofs, dist_lut, varargin{:} );
            elseif kernels==2 %epanechnikov
                s = 'kde_decode_epanechnikov';
                f = @(stim, stim_grid, stim_k, stim_w, resp, resp_k, resp_w, test_resp, ofs, dist_lut, varargin) kde_decode_epanechnikov( stim, stim_grid, resp, test_resp, ofs, dist_lut, varargin{:} );
            else %kronecker or categorical
                s = 'kde_decode_kronecker';
                f = @(stim, stim_grid, stim_k, stim_w, resp, resp_k, resp_w, test_resp, ofs, dist_lut, varargin) kde_decode_kronecker( stim, stim_grid, resp, test_resp, ofs, dist_lut, varargin{:} );
            end
            
        end

    end
    
end

        
        
