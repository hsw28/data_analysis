function f = create_filter(varargin)

if nargin<1
    help(mfilename)
    return
end

if ischar(varargin{1})
    if strcmp(varargin{1}, 'or')
        op = 'or';
    else
        op = 'and';
    end
    varargin = varargin(2:end);
    nvar = nargin-1;
else
    op = 'and';
    nvar = nargin;
end

if mod(nvar,2)==1
    error('Odd number of input arguments')
end

for k=1:2:nargin
    
    if isvector(varargin{k}) %1d case
        %check variable
        if k==1
            n = numel(varargin{k});
            f = true(n,1);
        elseif n~=numel(varargin{k})
            error('variables have unequal number of elements')
        end
        %check filter
        if isempty(varargin{k+1})
            continue
        elseif isnumeric(varargin{k+1}) && size(varargin{k+1},2)==2
            if strcmp(op,'and')
                 f = f & inseg( varargin{k}(:), varargin{k+1} );
            else
                 f = f | inseg( varargin{k}(:), varargin{k+1} );
            end
        else
            error('Invalid filter');
        end
    else
        error('Only 1d variables are supported')
    end
    
end