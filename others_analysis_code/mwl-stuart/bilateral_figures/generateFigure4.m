function generateFigure4(e)
open_pool;
%% Load Data for the figure
% dset = dset_load_all('spl11', 'day15', 'run');

if ~exist('e','var') || ~isstruct(e)
    e = exp_load('/data/spl11/day15', 'epochs', 'run', 'data_types', {'clusters', 'pos'});
    e = process_loaded_exp2(e);
end

close all

generateFigure3_helper(e);

%%