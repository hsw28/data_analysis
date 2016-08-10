function [times_in_wins logicals] = gh_times_in_timewins(all_times,wins)
% [times_in_wins logicals] = gh_times_in_timewins(all_times,wins)
%
%  Return list of times falling within windows, and a logical table
%
%  -times_in_wins is a list of all times from all_times that were in at
%    least one win
%  -logicals is a logical array of size all_times indicating whether each
%    time was in at least one win
%
%  -all_times is a list of times to test
%  -wins is an nx2 array of intervals


%wins

warning('gh_times_in_timewins:deprecated','Deprecated function.  Prefer gh_points_in_segs.')

logicals = zeros(size(all_times));
times_in_wins = [];


% want to assume that col 1 is win start times, col 2 is win end times
if(size(wins,2)>2)
    wins = wins';
    disp('transposed timewins in gh_times_in_timewins');
end

if(size(wins,2) ~= 2)
    error('start times should be in col 1, end times in col 2.  Wins matrix is the wrong size.');
end

n_wins = size(wins, 1);

wins_cell = mat2cell(wins, ones(n_wins,1), 2);

for i = 1:size(wins,1)
    this_logicals = and((all_times >= wins(i,1)),(all_times <= wins(i,2)));
    times_in_wins = [times_in_wins, reshape(all_times(this_logicals),1,[])];
    logicals = logicals + this_logicals;
end
logicals = logical(logicals);

return