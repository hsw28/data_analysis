function c = gh_circular_subtract(b,a,varargin)
% gh_circular_subtract returns the circular difference first arg minus
% second

p = inputParser();
p.addParamValue('output_range',[-pi,pi], @(r) abs(diff(r)-2*pi) < 1e-100);
p.parse(varargin{:});
opt = p.Results;

if(all(size(b) == size(a)) || all(size(a) == 1) || all(size(b) == 1))
    c = b - a;
else
    c = bsxfun(@minus, b, a);
end

c = mod((c - opt.output_range(1)),2*pi) + opt.output_range(1);

