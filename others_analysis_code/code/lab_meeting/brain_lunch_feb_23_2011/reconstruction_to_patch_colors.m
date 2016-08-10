function [patch_colors] = reconstruction_to_patch_colors(r_pos, ...
   track_info, varargin)

 p = inputParser();
 p.addParamValue('timewin', [r_pos(1).tstart, r_pos(1).tend]);
 p.addParamValue('norm_c',true);
 p.addParamValue('pdf_exponentiator',1);
 p.addParamValue('framerate', 20);
 p.addParamValue('time_compress',0.2);
 p.addParamValue('thresh', 0.15);
 p.parse(varargin{:});
 opt = p.Results;
 
 n_trackinfo_segs = numel(track_info.field_lin_bin_centers);
 n_r_pos_track_segs = size(r_pos(1).pdf_by_t,1);
 n_rpos = numel(r_pos);
 
 native_dt = r_pos(1).ts(2) - r_pos(1).ts(1);
 native_freq = 1/native_dt;
 data_time_interval = opt.timewin(2) - opt.timewin(1);
 n_native_ts = data_time_interval * native_freq;
 
 n_ts = ceil(data_time_interval * opt.framerate / opt.time_compress);
 ts = linspace( opt.timewin(1), opt.timewin(2), n_ts );
 
 patch_colors = zeros([n_ts, n_trackinfo_segs,3]);
 
 for n = 1:3
     this_ind = min([n, n_rpos]);
     new_pdf_by_t = interp1( r_pos(this_ind).ts', r_pos(this_ind).pdf_by_t', ts','linear');
     if(opt.norm_c)
         new_pdf_by_t = new_pdf_by_t ./ max(max(new_pdf_by_t));
     end
     new_pdf_by_t = new_pdf_by_t .^ opt.pdf_exponentiator;
     new_pdf_by_t = 0.1 + 0.9.*new_pdf_by_t;
     
     if(opt.norm_c)
%         new_pdf_by_t = bsxfun(@rdivide, new_pdf_by_t, max(max(new_pdf_by_t,[],2), 0.1 .* ones(n_ts,1)));
         new_pdf_by_t = new_pdf_by_t ./ max(max(new_pdf_by_t));
     end
     
     if(~isempty(opt.thresh))
         new_pdf_by_t (new_pdf_by_t < opt.thresh) = 0.1;
     end
     
     patch_colors(:,:,n) = new_pdf_by_t;
 end