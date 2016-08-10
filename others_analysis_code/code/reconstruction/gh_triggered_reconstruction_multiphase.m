function r_pos_trig = gh_triggered_reconstruction_multiphase(r_pos_in,pos,varargin)

r_pos_trig = gh_triggered_reconstruction(r_pos_in,pos,varargin{:});

n_phases = size(r_pos_trig(1).pdf_by_t,2);
mid_ind = (n_phases + 1)/2

if(~(mod(n_phases,2)))
    disp('Warning, there are an even number of columns.  I am taking the floor middle one');
    mid_ind = floor(mid_ind);
end

% we'll calculate one phase for each timebin in the orig, then replace each
% time column with a phase column
phases = linspace(-pi, pi, n_phases);
tstart = -pi;
tend = pi;

for n = 1:numel(phases)
    this_r_pos_trig = gh_triggered_reconstruction(r_pos_in,pos,'phase',phases(n),varargin{:});
    for this_chan = 1:numel(r_pos_in) % iterate over color channels
        r_pos_trig(this_chan).pdf_by_t(:,n) = this_r_pos_trig(this_chan).pdf_by_t(:,mid_ind);
    end
end