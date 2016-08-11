function the_ratio = gh_spectrum(eeg_r,varargin)

p = inputParser();
p.addParamValue('sample_timewin',[eeg_r.raw.tstart,eeg_r.raw.tend]);
p.addParamValue('baseline_timewin',[]);
p.addParamValue('sample_ind',2);
p.addParamValue('baseline_ind',2);
p.addParamValue('frequency_vector',[]);
p.addParamValue('draw',true);
p.parse(varargin{:});
opt = p.Results;

Fs = eeg_r.raw.samplerate;

eeg_r_sample = contwin_r(eeg_r,opt.sample_timewin);
sample_data = eeg_r_sample.raw.data(:,opt.sample_ind);
sample_Hs = spectrum.welch;
sample_Hopts = msspectrumopts(sample_Hs,sample_data);
set(sample_Hopts,'Fs',Fs);
if(~isempty(opt.frequency_vector))
    set(sample_Hopts,'FreqPoints','User Defined');
    sample_Hopts.FrequencyVector = opt.frequency_vector;
end
sample_Hmss = msspectrum(sample_Hs,sample_data,sample_Hopts);
Hmss = copy(sample_Hmss);

if(~isempty(opt.baseline_timewin))
    
    eeg_r_baseline = contwin_r(eeg_r,opt.baseline_timewin);
    baseline_data = eeg_r_baseline.raw.data(:,opt.baseline_ind);
    baseline_Hs = spectrum.welch;
    baseline_Hopts = msspectrumopts(baseline_Hs,baseline_data);
    set(baseline_Hopts,'Fs',Fs);
    if(~isempty(opt.frequency_vector))
        set(baseline_Hopts,'FreqPoints','User Defined');
        baseline_Hopts.FrequencyVector = opt.frequency_vector;
    end
    baseline_Hmss = msspectrum(baseline_Hs,baseline_data,baseline_Hopts);
    %Hmss.Data = sample_Hmss.Data ./ baseline_Hmss.Data;
    the_ratio = sample_Hmss.Data ./ baseline_Hmss.Data;
    %Hmss.Data = exp(log(sample_Hmss.Data) - log(baseline_Hmss.Data));
end

if(opt.draw)
    plot(Hmss.Frequencies,the_ratio);
end