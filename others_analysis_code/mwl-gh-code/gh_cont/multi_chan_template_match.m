function [sample_center_time,center_corr] = multi_chan_template_match(sample_cdat,timewin,varargin)

p = inputParser();
p.addParamValue('speedup_factor',1,@isreal); % factor by which sample is sped up w/ respect to template
p.parse(varargin{:});
opt = p.Results;

n_chans = size(sample_cdat.data,2);
sample_timestamp = conttimestamp(sample_cdat);
template_center_time = mean(timewin);
template_cdat = contwin(sample_cdat,timewin);
template_cdat = contresamp(template_cdat,1/opt.speedup_factor);
template_lin_data = reshape(template_cdat.data,[],1);
template_end_ind = size(template_cdat.data,1);
template_center_ind = floor(template_end_ind/2);
n_template_samp = template_end_ind;
n_sample_samp = size(sample_cdat.data,1);
n_temp_in_sample = n_sample_samp + 1 - n_template_samp;
sample_center_time = zeros(1,n_temp_in_sample);
center_corr = zeros(1,n_temp_in_sample);

for i = 1:n_temp_in_sample
    this_sample_start_ind = i;
    this_sample_end_ind = i + n_template_samp - 1;
    this_sample_start_time = sample_timestamp(this_sample_start_ind);
    this_sample_end_time = sample_timestamp(this_sample_end_ind);
    this_sample_center_time = mean([this_sample_start_time,this_sample_end_time]);
    sample_center_time(i) = this_sample_center_time;
    this_sample_lin_data = reshape(sample_cdat.data(this_sample_start_ind:this_sample_end_ind,:),[],1);
    this_corr = corr([template_lin_data,this_sample_lin_data]);
    %size(this_corr)
    center_corr(i) = this_corr(1,2);
end