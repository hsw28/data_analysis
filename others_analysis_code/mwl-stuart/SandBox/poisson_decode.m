classdef poisson_decode < handle
%POISSON_DECODE general poisson based decoding

    properties (SetAccess=protected)
        stimulus
        nstimulus
        spike_stimulus
        spike_response
        nresponse
        Pstim
        Pstimspike
        mu
    end
    
    properties (Access=protected)
        stimulus_kernel_type_data
        response_kernel_type_data
        stimulus_kernel_width_data
        response_kernel_width_data
        stimulus_grid_data
        grid
        stimulus_grid_size        
        stimulus_range
        flag_init = false;
    end
    
    properties (Dependent=true)
        stimulus_grid
        stimulus_kernel_type
        response_kernel_type
        stimulus_kernel_width
        response_kernel_width
    end
    
    methods
        
        function obj=poisson_decode( t, stimulus, spike_stimulus, spike_response, varargin)
            %POISSON_DECODE constructor
            %
            %  obj=POISSON_DECODE(t,stimulus,spike_stimulus,spike_response, ... )
            %  where t is the total measurement time, stimulus (e.g.
            %  position) is a N-by-S matrix, spike_stimulus is a
            %  Nspike-by-S matrix, spike_response (e.g. amplitude or
            %  cluster identity) is a Nspike-by-R matrix.
            %   stimulus_grid - length S cell array of vectors
            %   stimulus_kernel_type - length S vector (0=gaussian,1=von Mises,2=box)
            %   response_kernel_type - length R vector
            %   stim_kernel_width - length S vector (stand. dev., kappa or box width)
            %   resp_kernel_width - length R vector
            %   prior - true/false (NOT IMPLEMENTED)
            %   downsample - 0...1 (default=1, no downsampling)
            %
                     
            options = struct( 'stimulus_grid', [], 'stimulus_kernel_type', [], 'response_kernel_type', [], ...
                'stimulus_kernel_width', [], 'response_kernel_width', [], 'prior', false, 'downsample', 1);
            options = parseArgs(varargin,options);
            
            if nargin<4
                error('poisson_decode:poisson_decode:invalidArguments', 'Invalid number of arguments')
            end
            
            %check measurement time
         
            if ~isnumeric(t) || ~isscalar(t) || t<=0
                error('poisson_decode:poisson_decode:invalidArguments', 'Invalid measurement time')
            end
            
            %check simulus matrix
            if ~isnumeric(stimulus) || ndims(stimulus)~=2 || any(isnan(stimulus(:)))
                error('poisson_decode:poisson_decode:invalidArguments', 'Invalid stimulus matrix')
            end
            obj.nstimulus = size(stimulus,2);
            obj.stimulus_range = [ min(stimulus) ; max(stimulus) ];
            obj.stimulus = stimulus;
            
            %check spike stimulus matrix
            if ~iscell(spike_stimulus)
                spike_stimulus = {spike_stimulus};
            end
            
            if ~all(cellfun( @(x) isnumeric(x) && ndims(x)==2 && size(x,2)==obj.nstimulus && ~any(isnan(x(:))), spike_stimulus ))
                error('poisson_decode:poisson_decode:invalidArguments', 'Invalid spike stimulus matrix')
            end
            Nspikes = cellfun( @(x) size(x,1), spike_stimulus(:) );
            obj.spike_stimulus = spike_stimulus;
            
            %check spike response matrix
            if ~iscell(spike_response)
                spike_response = {spike_response};
            end
            obj.nresponse = size( spike_response{1}, 2);
            if ~all(cellfun( @(x) isnumeric(x) && ndims(x)==2 && size(x,2)==obj.nresponse && ~any(isnan(x(:))), spike_response )) || ...
                    ~isequal( Nspikes, cellfun( @(x) size(x,1), spike_response(:) ) );
                error('poisson_decode:poisson_decode:invalidArguments', 'Invalid spike response matrix')
            end
            obj.spike_response = spike_response;
            
            %downsample densities
            if ~isnumeric(options.downsample) || ~isscalar(options.downsample) || options.downsample<=0 || options.downsample>1
                error('poisson_decode:poisson_decode:invalidArgument', 'Invalid downsample option')
            end
            if options.downsample<1
                for k=1:numel(obj.spike_stimulus)
                    ii = randsample( Nspikes(k), round(options.downsample*Nspikes(k)) );
                    obj.spike_stimulus{k} = obj.spike_stimulus{k}(ii,:);
                    obj.spike_response{k} = obj.spike_response{k}(ii,:);
                end
            end
            
            obj.stimulus_grid = options.stimulus_grid;
            obj.stimulus_kernel_type = options.stimulus_kernel_type;
            obj.response_kernel_type = options.response_kernel_type;
            obj.stimulus_kernel_width = options.stimulus_kernel_width;
            obj.response_kernel_width = options.response_kernel_width;

            %compute mean rate
            obj.mu = Nspikes./t;            
            
            obj.flag_init = true;
            obj.update_stimulus_pdf();
            
        end
        
        function update_stimulus_pdf(obj)
            if obj.flag_init
                obj.Pstim = compute_stimulus_pdf( obj, obj.stimulus );
                obj.Pstimspike = cellfun( @obj.compute_stimulus_pdf, obj.spike_stimulus, 'UniformOutput', false );
            end
        end
        function p=compute_stimulus_pdf(obj,x)
            %w = obj.stimulus_kernel_width;
            %w( obj.stimulus_kernel_type~=0 ) = 1;
            p = amp_decode4_c( zeros(size(x,1),0), x, zeros(1,0), obj.grid, [], [], obj.stimulus_kernel_type, obj.stimulus_kernel_width );
            p = p./sum(p(:));
        end
        
        function val=get.stimulus_grid(obj)
            val = obj.stimulus_grid_data;
        end
        function set.stimulus_grid(obj,val)
            %check stimulus grid
            if isempty(val)
                val = ones(1,obj.nstimulus)*10;
            end
            
            if isnumeric(val) && isvector(val) && numel(val)==obj.nstimulus && all(val>0)
                tmp = cell(1,obj.nstimulus);
                for k=1:obj.nstimulus
                    tmp{k} = linspace( obj.stimulus_range(1,k), obj.stimulus_range(2,k), val(k) );
                end
                val = tmp;
            elseif ~iscell(val) || numel(val)~=obj.nstimulus || ~all( cellfun( @(x) isnumeric(x)&&isvector(x), val(:) ) )
                error('poisson_decode:set_stimulus_grid:invalidArguments', 'Invalid stimulus grid')
            end
            obj.stimulus_grid_data = val;
            obj.stimulus_grid_size = cellfun( 'prodofsize', val );
            
            %create grid
            [g{1:obj.nstimulus}] = ndgrid( val{:}, 1 );
            g = cellfun( @(x) x(:), g, 'UniformOutput', false );
            g = cat(2, g{:} );
            obj.grid = g;
            
            %update PDFs
            update_stimulus_pdf(obj);
        end
        
        function val=get.stimulus_kernel_type(obj)
            val = obj.stimulus_kernel_type_data;
        end
        function val=get.response_kernel_type(obj)
            val = obj.response_kernel_type_data;
        end
        function val=get.stimulus_kernel_width(obj)
            val = obj.stimulus_kernel_width_data;
        end
        function val=get.response_kernel_width(obj)
            val = obj.response_kernel_width_data;
        end
        function set.stimulus_kernel_type(obj,val)
         %check stimulus type
            if isempty(val)
                val = zeros(1,obj.nstimulus); %Gaussian kernel
            elseif ~isnumeric(val) || ~isequal(size(val),[1 obj.nstimulus]) || any( val<0 | val>2 )
                error('poisson_decode:set_stimulus_kernel_type:invalidArguments', 'Invalid stimulus kernel type')
            end
            obj.stimulus_kernel_type_data = round(val);
            %update PDFs
            update_stimulus_pdf(obj);
        end
        function set.response_kernel_type(obj,val)
         %check response type
            if isempty(val)
                val = zeros(1,obj.nresponse); %Gaussian kernel
            elseif ~isnumeric(val) || ~isequal(size(val),[1 obj.nresponse]) || any( val<0 | val>2 )
                error('poisson_decode:set_response_kernel_type:invalidArguments', 'Invalid response kernel type')
            end
            obj.response_kernel_type_data = round(val);
        end
        function set.stimulus_kernel_width(obj,val)
            %check stimulus kernel width
            if isempty(val)
                val = diff(obj.stimulus_range)./50;
            elseif ~isnumeric(val) || ~isequal( size(val), [1 obj.nstimulus] ) || any( val<0 )
                error('poisson_decode:set_stimulus_kernel_width:invalidArguments', 'Invalid stimulus kernel widths')
            end
            obj.stimulus_kernel_width_data = val;
            %update PDFs
            update_stimulus_pdf(obj);
        end
        function set.response_kernel_width(obj,val)
            %check response kernel width
            if isempty(val)
                val = ones(1,obj.nresponse);
            elseif ~isnumeric(val) || ~isequal( size(val), [1 obj.nresponse] ) || any( val<0 )
                error('poisson_decode:set_response_kernel_width:invalidArguments', 'Invalid response kernel widths')
            end
            obj.response_kernel_width_data = val;
        end
           
        function P = decode(obj, test_response, dt)
            %DECODE
            %
            %  p=DECODE(obj,test_response,dt)
            %
            
            if nargin<3
                error('poisson_decode:decode:invalidArguments', 'Need at least 3 arguments')
            end
            
            if ~iscell(test_response)
                test_response = {test_response};
            end
            
            if numel(test_response)~=numel(obj.spike_response) || ~all(cellfun( @(x) isnumeric(x) && ndims(x)==2 && size(x,2)==obj.nresponse && ~any(isnan(x(:))), test_response ))
                error('poisson_decode:decode:invalidArguments', 'Invalid test responses' )
            end
            
            if ~isnumeric(dt) || ~isscalar(dt) || dt<=0
                error('poisson_decode:decode:invalidArgument', 'Invalid dt')
            end
                        
            nspikes = cellfun( @(x) size(x,1), test_response );
            
%             ws = obj.stimulus_kernel_width_data;
%             ws( obj.stimulus_kernel_type_data~=0 ) = 1;
%             wr = obj.response_kernel_width_data;
%             wr( obj.response_kernel_type_data~=0 ) = 1;
            
            P = 0;

            for k=1:numel(test_response)
                %compute P(stimulus|spike,response)
                %tmp = amp_decode4_c(bsxfun(@rdivide,obj.spike_response{k},wr), bsxfun(@rdivide,obj.spike_stimulus{k},ws), bsxfun( @rdivide, test_response{k},wr), bsxfun(@rdivide,obj.grid,ws), obj.response_kernel_type_data, obj.response_kernel_width_data, obj.stimulus_kernel_type_data, obj.stimulus_kernel_width_data );
               
                if isempty(test_response{k}) && ~isempty(obj.spike_response{1})  %% don't care about empty response if there are no amplitudes, b/c without amplitude information the response vectors are always empty (this was a wicked bug to find)                 
                    tmp = ones(size(obj.stimulus_grid))*.0001;
                else
                    tmp = amp_decode4_c( obj.spike_response{k}, obj.spike_stimulus{k}, test_response{k}, obj.grid, obj.response_kernel_type_data, obj.response_kernel_width_data, obj.stimulus_kernel_type_data, obj.stimulus_kernel_width_data );
                    %tmp = tmp + .00001;
                   
                    tmp = sum(log(tmp),1) - nspikes(k).*log(obj.Pstim);    
                end

                %tmp = tmp.*exp(-dt.*obj.mu(k).*obj.Pstimspike{k}./obj.Pstim);
                tmp = tmp - dt.*obj.mu(k).*obj.Pstimspike{k}./obj.Pstim;
                
                %tmp = tmp./nansum(tmp(:));
                P = P + tmp;

               
                %tmp = bsxfun( @rdivide, tmp, nansum(tmp,2) );
                %P=P+nansum(log( tmp ),1 );
                %P=P-nspikes(k).*log(obj.Pstim) - dt.*obj.mu(k).*obj.Pstimspike{k}./obj.Pstim;
            end
            
            %P=P.*exp(-dt.*r);
            
            P = exp(P-nanmax(P));
            P = P./nansum(P(:));

        end
        
        
    end
    
end