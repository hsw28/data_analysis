classdef pstruct < handle
%PSTRUCT handle object version of struct
%
%  s=PSTRUCT(...) accepts the same input aguments as struct()
%

    properties (Access=protected)
        data = struct();
    end
    
    methods
        
        function obj=pstruct(varargin)
            
            if nargin>0
                try
                    s = struct( varargin{:} );
                catch me
                    error('pstruct:pstruct:invalidArguments', 'Invalid arguments')
                end
                
                obj.data = s;
                
            end
            
        end
   
        function varargout = subsref(obj,s)
            
            ns = numel(s);
            
            val = obj.data;
            
            for k=1:ns
                
                switch s(k).type
                    case '()'
                        if isa(val,'pstruct')
                            val = pstruct( subsref( val, s(k) ) );
                        else
                            val = subsref( val, s(k) );
                        end
                    case '.'
                        if isstruct(val)
                            n = numel(val);
                            if n>1
                                %MATLAB BUG! this doesn't return a comma
                                %separated list! I.e. you would have to
                                %explicitly capture all outputs (like so:
                                %[y{1:n}]=subsref(...)
                                [varargout{1:n}] = builtin('subsref', val, s(k) );
%                                 try
%                                     %%POOR HACK
%                                     varargout{1} = reshape([varargout{:}],size(val));
%                                 catch
%                                     %%POOR HACK
%                                     varargout = { reshape( {varargout{:}}, size(val) ) };
%                                 end
                                if k<ns
                                    error('pstruct:subsref:invalidIndex', 'Invalid indexing')
                                end
                                return
                            else
                                val = subsref( val, s(k) );
                            end
                        else
                            val = subsref( val, s(k) );
                        end
                    otherwise
                        error('pstruct:subsref:invalidArgument', 'Invalid indexing')
                end
                
            end
            
            varargout{1} = val;

        end
        
        function obj=subsasgn(obj,s,val)
            obj.data = builtin('subsasgn',obj.data,s,val);
        end
        
        function n=numel(obj)
            n = numel(obj.data);
        end
        
        function disp(obj)
            disp(obj.data)
        end
        
        function b=isstruct(obj)
            b=isstruct(obj.data);
        end
        
        function b=class(obj)
            b=class(obj.data);
        end
        
        function val=fieldnames(obj,varargin)
            val=fieldnames(obj.data,varargin{:});
        end
        
        function b=isfield(obj,varargin)
            b=isfield(obj.data,varargin{:});
        end
        
        function b=isa(obj,c)
            b = isequal(c,'struct') || builtin('isa',obj,c);
        end
        
        function [obj, perm] = orderfields( obj, arg2 )
            if isa(arg2,'pstruct')
                [obj.data, perm] = orderfields( obj.data, arg2.data );
            else
                [obj.data, perm] = orderfields( obj.data, arg2 );
            end
        end
           
        function f=getfield(obj,varargin)
            f=getfield(obj.data,varargin{:});
        end
        
        function obj=setfield(obj,varargin)
            obj.data=setfield(obj.data,varargin{:});
        end
        
        function obj=rmfield(obj,varargin)
            obj.data=rmfield(obj.data,varargin{:});
        end
        
        function c=struct2cell(obj)
            c=struct2cell(obj.data);
        end
        
    end
    
end