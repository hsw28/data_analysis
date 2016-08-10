function [enames,ebounds] = get_epoch_info()
% GET_EPOCH_INFO gets mwl-style *.eopch file into matlab form
%
% enames is a cell array of epoch names
% ebounds is a 2xn_epochs array of start/stop times

% embarassingly bulky.  Someone better at file handling might clean this
% up?

fname = dir('*.epoch');

file = textread(fname(1).name,'%s','delimiter','\n','whitespace','','commentstyle','matlab');
nepoch = numel(file);
ebounds = zeros(2,nepoch);
ename = cell(1,nepoch);
first_space = zeros(1,nepoch);
for i = 1:nepoch
    file{i};
    spaces = strfind(file{i},'	'); % character btw the quotes is a TAB
    first_space = spaces(1);
    this_str = file{i};
    enames{i} = this_str(1:first_space-1);
    bounds = sscanf(this_str,'%*s %f %f');
    ebounds(:,i) = bounds';
end