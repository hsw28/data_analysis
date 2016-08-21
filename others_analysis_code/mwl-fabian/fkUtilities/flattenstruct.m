function z = flattenstruct( s )
%FLATTENSTRUCT extract field names of nested struct
%
%  z=FLATTENSTRUCT(s) returns a cell vector with field names (using
%  dot notation) in the (scalar) nested struct s.
%

%  Copyright 2009 Fabian Kloosterman

    
z = cell(0,2);

if nargin<1 || ~isstruct(s) || ~isscalar(s)
    error('flattenstruct:invalidArgument', 'Need a scalar struct')
end

recursefcn( s, '' );

    function recursefcn( s, base )
        fn = fieldnames(s);
        
        if ~isempty(base)
            base = [base '.'];
        end
        
        for k=1:numel(fn)
            
            if isstruct(s.(fn{k}))
                if ~isscalar(s.(fn{k}))
                    error('flattenstruct:invalidArgument', 'Only scalar (sub)structs are supported')
                else
                    recursefcn( s.(fn{k}), [base fn{k}] );
                end
            else
                z(end+1,:) = {[base fn{k}], s.(fn{k})};
            end
        end
            
            
    end

end