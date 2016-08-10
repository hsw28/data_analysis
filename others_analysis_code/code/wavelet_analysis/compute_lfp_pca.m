function [pca_coefs,pca_score,pca_latent,coefs_array,comp_pca_opt] = compute_lfp_pca(eeg_r,varargin)

p = inputParser;
p.addParamValue('spectrum_method','wavelet');
p.addParamValue('prewhiten',true);
p.addParamValue('spec_freqs',4:120);
p.addParamValue('wavelet','mexh');
p.addParamValue('clip_edges',true);
p.addParamValue('smooth_coefs',true);
p.addParamValue('log_coefs',true);
p.addParamValue('verbose',false);
p.parse(varargin{:});
opt = p.Results;

fs = eeg_r.raw.samplerate;
sample_scales = [0.01:0.01:500];
sample_freqs = scal2frq(sample_scales,opt.wavelet,1/fs);
freq_vec = opt.spec_freqs;
if(or(min(freq_vec) < min(sample_freqs), max(freq_vec) > max(sample_freqs)))
    error('spec_freqs out of bounds.  Modify sample_scales in m file to try more scales.');
end
scale_vec = interp1(sample_freqs,sample_scales,opt.spec_freqs);

ts = conttimestamp(eeg_r.raw);

n_scale = length(scale_vec);
n_ts = length(ts);

n_trode = size(eeg_r.raw.data,2);

% make a wavelet coefs array
% each row is one time point
% row_t1:  Trode1{freq1,freq2,freq3}, Trode2{freq1,freq2,freq3} ... 
coefs_data = zeros(n_ts,n_trode*n_scale);
coefs_array = zeros(n_scale,n_ts,n_trode);
if(strcmp(opt.spectrum_method,'spectrogram')) % spectrogram doesn't return same-sized matrix
    params.Fs = eeg_r.raw.samplerate;
    params.tapers = [3 5];
    movingwin = [0.1, 0.013];
    [sample_s,sample_t,sample_f] = mtspecgramc(eeg_r.raw.data(:,1), movingwin, params);
    opt.spec_freqs = sample_f;
    n_ts = length(sample_t);
    n_scale = size(sample_s,2);
    coefs_data = zeros(n_ts,n_trode*n_scale);
    coefs_array = zeros(n_scale,n_ts,n_trode);
end
for n = 1:n_trode
    this_data = eeg_r.raw.data(:,n);
    if(opt.prewhiten)
        if(opt.verbose); disp('Pre-whitening signal.');end;
        [a,e] = arcov(this_data,2);
        a = real(a);
        e = sqrt(e);
        this_data2 = filter(a,e,this_data);
        if(opt.verbose)
            ax(1) = subplot(1,2,1); spectrogram(this_data);
            ax(2) = subplot(1,2,2); spectrogram(this_data2);
            linkaxes(ax,'y');
        end
        this_data = this_data2;
    end

    if(strcmp(opt.spectrum_method,'wavelet'))
        disp(['computing continuous wavelet transform on tetrode ', num2str(n), ' of ', num2str(n_trode)]);
        this_coefs = cwt(this_data,scale_vec,opt.wavelet);
        if(opt.smooth_coefs)
           for m = 1:size(this_coefs,1)
               this_coefs(m,:) = smooth(abs(this_coefs(m,:)),1/(freq_vec(m)) * fs);
           end
        end
    elseif(strcmp(opt.spectrum_method,'spectrogram'))
        params.Fs = eeg_r.raw.samplerate;
        params.tapers = [3 5];
        movingwin = [.100 .013]; % 100ms window, 13 ms slides
        [S,t,f] = mtspecgramc( this_data, movingwin, params );
        this_coefs = S';
    else
        error('Unrecognized spectrum_method.  Should be wavelet or spectrogram')
    end
    
    coefs_data(:,( (1:n_scale) + (n-1)*n_scale)) = this_coefs';
    coefs_array(:,:,n) = this_coefs;
end

if(opt.log_coefs)
    coefs_data = log(coefs_data);
end

if(opt.clip_edges)
    max_per = 1/(min(freq_vec));
    n_clip_samp = round(max_per * fs);
    coefs_data = coefs_data((1+n_clip_samp):(end-n_clip_samp),:);
    coefs_array = coefs_array(:,(1+n_clip_samp):(end-n_clip_samp),:);
end

display('Performing pca');
[pca_coefs,pca_score,pca_latent] = princomp(coefs_data);
comp_pca_opt = opt;
