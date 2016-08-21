function [operations] = operation_definitions(varargin)
% OPERATIONS = EXP_OPERATION_DEF(operation_id)
%
% converts numerical operation ID's into operations strings, user input
% will be prompted if required to complete the operation
%
% Valid Operations:
%    1 - Calculate tuning curves
%    2 - Calculate global multi-unit
%    3 - Calculate regional multi-unit
%    4 - Calculate multi-unit bursts 
%    5 - Calculate global ripple bursts
%    6 - Calculate regional ripple bursts
%    7 - Load tetrode anatomy
%    8 - Load eeg anatomy
%    9 - Sort clusters by tuning curve
%   10 - Calcuate cluster statistics
%

operations = ...
       {'calc_tc',...
        'calc_global_mu',...
        'calc_local_mu',...
        'calc_mu_bursts',...
        'calc_global_rip',...
        'calc_local_rip',...
        'load_tetrode_anatomy',...
        'load_eeg_anatomy', ...
        'sort_clusters',...
        'calc_cl_stats'}; 

% operations = ...
       {'calc_tc','load_tetrode_anatomy', 'load_eeg_anatomy', 'calc_global_mu', 'calc_mu_bursts'};
%     
if nargin == 1
    idx = varargin{1};
    if ~ischar(idx) && min(idx)>0 && max(idx) < 11
        operations = operations(idx);
    else
        error;
    end
else
    error('Invalid input, must by numeric vector or empty');
end
