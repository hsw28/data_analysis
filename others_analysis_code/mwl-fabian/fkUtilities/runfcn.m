function varargout=runfcn( p, varargin ) %#ok
%RUNFCN run a function that is not on the path
%
%  [...]=RUNFCN(p,...) runs the function specified by the file p
%        and returns the output arguments. Additional input
%        arguments are passed to the function.
%

%  Copyright 2009 Fabian Kloosterman


cur = cd;

[p,s,ext] = fileparts( p );

if ~isempty(p)
    
    if exist( p, 'dir' )
        
        cd( p );
        
        w = which( s );

        if ~isempty(w)
        
            [wp,ws,wext] = fileparts(w);
      
            if ispc
                cont = ~strcmpi(wp,pwd) | ~strcmpi(ws,s) | ...
                    (~isempty(ext) & ~strcmpi(wext,ext));
            else
                cont = ~isequal(wp,pwd) | ~isequal(ws,s) | ...
                    (~isempty(ext) & ~isequal(wext,ext));
            end
      
            if cont
                cd(cur)
                rehash;
                error('runfcn:fileNotFound', 'File not found or cannot execute')
            end
            
            try
                eval( ['[varargout{1:nargout}]=' s '(varargin{:});'] );
            catch ME
                cd(cur)
                rehash;
                rethrow(ME)
            end                
            
        else
            cd(cur);
            rehash;
            error('runfcn:fileNotFound','File not found')
        end
        
        cd(cur);
        rehash;
        
    else
        
        error('runfcn:fileNotFound', 'File not found')
        
    end
   
else
    
    if exist( s, 'file' )
        eval( ['[varargout{1:nargout}]=' s '(varargin{:});'] );
    else
        
        error('runfcn:fileNotFound', 'File not found')
        
    end
    
end
        
