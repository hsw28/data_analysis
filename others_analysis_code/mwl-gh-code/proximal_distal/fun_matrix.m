function m = fun_matrix(dataset, fun, varargin)
% dataset: struct array
%  dataset(n).label = set name (eg 'tt01')
%  dataset(n).data  = set data (eg [spiketime_1, ..., spiketimen])
% fun:  a function of two dataset rows returning a single value
%   eg @(x,y) corr(x.data, y.data)

p = inputParser();
p.addParamValue('symmetric', false);
p.addParamValue('antisymmetric',false);
p.addParamValue('zero_diagonal',false);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

if(~isfield(dataset,'data'))
    error('fun_matrix:invalid_input',...
        'Wrong input for fun_matrix.  See help fun_matrix');
end

n_rows = numel(dataset);

m = eye(n_rows);

% Build the indices
if(opt.zero_diogonal)
    fst = 2;
else
    fst = 1;
end

if(opt.symmetric)
    r = 1:
for i = 2:n_rows