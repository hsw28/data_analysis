function new_s = gh_union_segs(s1,s2,varargin)

p = inputParser();
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

%  |||||    ||||    ||||||||||   ||    ||||  s1
%    ||   ||||         |||||||||||   |       s2
%  S STT  S ST T    S  S     T   -T  - S  T
%
%  |||||  ||||||    |||||||||||||||  | ||||  new_s

% Maintain (start_count(a), stop_count(b)).  When a-b goes from 0 to 1,
% that is a boundary start.  When it goes from 1 to 0, that is a stop.

starts1 = cellfun(@(x) x(1), s1);
starts2 = cellfun(@(x) x(1), s2);

stops1  = cellfun(@(x) x(2), s1);
stops2  = cellfun(@(x) x(2), s2);

starts = [starts1, starts2];
stops =  [stops1,  stops2 ];

start_labels = 1  * ones(size(starts));
stop_labels  = -1 * ones(size(stops));


% combine boundaries
[bounds, i]     = sort([starts, stops]);
unsorted_labels = [start_labels, stop_labels];
labels          = unsorted_labels(i);
c_labels        = [0,cumsum(labels)];

union_starts = bounds((c_labels(2:end) == 1) &...
                      (diff(c_labels) > 0));
union_stops  = bounds((c_labels(2:end) == 0) &...
                      (diff(c_labels) < 0));
                  

%union_bound_inds = find(cumsum(labels) == 0);
n_new_segs = numel(union_starts);
%union_starts = bounds(floor((0:(n_new_segs-1)) + 1));
%union_stops  = bounds(floor((0:(n_new_segs-1)) + 2));

new_s = mat2cell([reshape(union_starts,1,[]); reshape(union_stops,1,[])],...
2, ones(1,n_new_segs));

if(opt.draw)
    gh_draw_segs( {s1,s2,new_s}, 'names', {'s1','s2','new_s'} );
    title([num2str(n_new_segs),' new segments']);
end
    