function eeg_r = contchans_r(eeg_r,varargin)

fn = fieldnames(eeg_r);

for i = 1:numel(fn)
    eeg_r.(fn{i}) = contchans(eeg_r.(fn{i}),varargin{:});
end
%eeg_r.theta = contchans(eeg_r.theta,varargin{:});
%eeg_r.phase = contchans(eeg_r.phase,varargin{:});
%eeg_r.env = contchans(eeg_r.env,varargin{:});

