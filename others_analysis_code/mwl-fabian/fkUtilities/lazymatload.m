classdef lazymatload < pstruct
%LAZYMATLOAD lazy loading of .mat file variables
%
%  s=LAZYMATLOAD(filename) returns a structure with a field for each
%  variable contained in the .mat file filename. The first time a field is
%  accessed, the associated data is loaded from the file and stored in the
%  struct.
%

    properties (SetAccess=protected)
        file
    end
    
    methods
        
        function obj=lazymatload(f)
            
            if nargin<1 || ~ischar(f) || ~exist( f, 'file' )
                error('lazymatload:lazymatload:invalidArgument', 'Need a valid file name')
            end
            
            s = who( '-file', f );
                
            obj.file = fullpath( f );
        
            if ~isempty(s)
                obj.data = cell2struct( repmat({'___lazy___'},numel(s),1), s(:), 1 );
            end
                
        end
        
        function val=subsref(obj,s)
            
            switch s(1).type
                case '.'
                    if isfield( obj.data, s(1).subs )
                        loadvar(obj,s(1).subs)
                    else
                        error('lazyloadmat:subsref:invalidField', 'Invalid field name')
                    end
                    
                    if numel(s)>1
                        val = subsref( obj.data.(s(1).subs), s(2:end) );
                    else
                        val = obj.data.(s(1).subs);
                    end
                    
                otherwise
                    val = subsref@pstruct( obj, s );
            end
            
        end
        
        function obj=subsasgn(obj,varargin) %#ok
            error('lazymatload:subsasgn:invalidMethod', 'Subscripted assignment not allowed')
        end
        function obj=rmfield(obj,varargin) %#ok
            error('lazymatload:rmfield:invalidMethod', 'Cannot remove field')
        end
        function obj=setfield(obj,varargin) %#ok
            error('lazymatload:setfield:invalidMethod', 'Cannot set field')
        end
        
        function load(obj,f)
            s = fieldnames( obj.data );
            if nargin<2
                %load all unloaded fields
                for k=1:numel(s)
                    loadvar(obj,s{k});
                end
            elseif (~ischar(f) && ~iscellstr(f)) || ~all(ismember(f,s))
                error('lazymatload:load:invalidFields', 'Invalid field names')
            else
                if ischar(f)
                    loadvar(obj,f);
                else
                    for k=1:numel(f)
                        loadvar(obj,f{k});
                    end
                end
            end
        end
        
        function unload(obj,f)
            s = fieldnames( obj.data );
            if nargin<2
                %unload all fields
                obj.data = cell2struct( repmat({'___lazy___'},numel(s),1), s(:), 1 );
            elseif (~ischar(f) && ~iscellstr(f)) || ~all(ismember(f,s))
                error('lazymatload:unload:invalidFields', 'Invalid field names')
            else
                if ischar(f)
                    obj.data.(f) = '___lazy___';
                else
                    for k=1:numel(f)
                        obj.data.(f{k}) = '___lazy___';
                    end
                end
            end
        end
        
    end
    
    methods  (Access=protected, Hidden=true)
        
        function loadvar(obj,v)
            if isequal( obj.data.(v), '___lazy___' )
                tmp = load( obj.file, v );
                obj.data.(v) = tmp.(v);
            end
        end
        
    end
        
end