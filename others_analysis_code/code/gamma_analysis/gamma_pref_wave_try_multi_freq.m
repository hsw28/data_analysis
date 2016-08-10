function gamma_pref_wave_try_multi_peak(eeg,rat_conv_table,varargin)

p = inputParser();
p.addParamValue('gamma_range',[15 235]);
p.addParamValue('gamma_step',10);
p.addParamValue('bandwidth',20);
p.addParamValue('stopwidth',30);
p.parse(varargin{:});
opt = p.Results;

gamma_centers = [opt.gamma_range(1):opt.gamma_step:opt.gamma_range(2)]';
gamma_wins = [gamma_centers - opt.stopwidth/2, gamma_centers - opt.bandwidth/2,...
    gamma_centers + opt.bandwidth/2, gamma_centers + opt.stopwidth/2];

for n = 1:length(gamma_centers)
    win = gamma_wins(n,:);
    eeg_r = prep_eeg_for_regress(eeg,'gamma',true,'gamma_win',win,'timewin_buffer',2);
    gh_gamma_pref_wave(eeg_r,rat_conv_table);
    title(['gamma [' num2str(win(1)),', ',num2str(win(2)),'. ',num2str(win(3)),', ',...
        num2str(win(4)),']']);
end