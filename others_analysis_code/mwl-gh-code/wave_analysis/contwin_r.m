function eeg_r = contwin_r(old_eeg_r,timewin)

f_names = fieldnames(old_eeg_r);
n_field = numel(f_names);

eeg_r = struct;

for n = 1:n_field
    % see 'dynamic field names' if confused
    name = f_names{n};
    this_one = old_eeg_r.(f_names{n});
    eeg_r.(f_names{n}) = contwin(old_eeg_r.(f_names{n}), timewin);
end

%eeg_r.raw = contwin(old_eeg_r.raw,timewin);
%eeg_r.theta = contwin(old_eeg_r.theta,timewin);
%eeg_r.phase = contwin(old_eeg_r.phase,timewin);
%eg_r.env = contwin(old_eeg_r.env,timewin);
%eeg_r.gamma = contwin(old_eeg_r.gamma,timewin);
%eeg_r.gammaphase = contwin(old_eeg_r.gammaphase,timewin);
%eeg_r.gammaenv = contwin(old_eeg_r.gammaenv,timewin);