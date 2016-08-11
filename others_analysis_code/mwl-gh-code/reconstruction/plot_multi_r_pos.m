function [h,t,d_pos] = plot_multi_r_pos(r_pos_array,pos,varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('draw_rat_pos',true);
p.addParamValue('split_figs',false,@islogical);
p.addParamValue('breakout_chans',false,@islogical);
p.addParamValue('draw_pdf',true,@islogical);
p.addParamValue('draw_centermarks',true,@islogical);
p.addParamValue('draw_p_at_mode',false,@islogical);
p.addParamValue('draw_mean',false,@islogical);
p.addParamValue('draw_mode',false,@islogical);
p.addParamValue('norm_c',false,@islogical);
p.addParamValue('log_scale',false,@islogical);
p.addParamValue('figure_quality',true);
p.addParamValue('e',0.5);
p.parse(varargin{:});
opt = p.Results;


opt.max_p = 0;
for n = 1 : numel(r_pos_array)
	  opt.max_p = max([opt.max_p, max(max(r_pos_array(n).pdf_by_t))]);
end

if(~isempty(opt.timewin))
    ts = linspace(r_pos_array(1).tstart,r_pos_array(1).tend,size(r_pos_array(1).pdf_by_t,2));
    keep_bool = and(ts >= opt.timewin(1), ts <= opt.timewin(2));
    new_ts = ts(keep_bool);
    for n = 1 : numel(r_pos_array)
        r_pos_array(n).tstart = new_ts(1);
        r_pos_array(n).tend =   new_ts(end);
        r_pos_array(n).pdf_by_t = r_pos_array(n).pdf_by_t(:,keep_bool);
    end
    
    pos.lin_filt = contwin(pos.lin_filt, opt.timewin);
    
end

if(opt.breakout_chans)
  n_r_pos = length(r_pos_array);
  n_plot = n_r_pos + 1;
  nrow = ceil(sqrt(n_plot));
  for n = 1:n_r_pos
    ax(n) = subplot(nrow,nrow,n);
    lfun_draw(r_pos_array(n),pos, opt);
  end
  subplot(nrow,nrow,n_plot);
  linkaxes(ax,'x');
end
lfun_draw(r_pos_array,pos, opt);
		    
function lfun_draw(r_pos,pos, opt)
  is_multi = length(r_pos) > 1;
  n_row = size(r_pos(1).pdf_by_t,1);
  n_col = size(r_pos(1).pdf_by_t,2);
  ts = linspace(r_pos(1).tstart,r_pos(1).tend,size(r_pos(1).pdf_by_t,2));
  if(~isempty(opt.timewin))
    ok_ts = ts >= opt.timewin(1) & ts <= opt.timewin(2);
    for n = 1:length(r_pos)
	      r_pos(n).pdf_by_t = r_pos(n).pdf_by_t(:,ok_ts);
              ts = ts(:,ok_ts);
              r_pos(n).tstart = min(ts);
              r_pos(n).tend = max(ts);
    end % end for
  end % end if

  if(opt.draw_pdf)
    img = zeros(size(r_pos(1).pdf_by_t,1),size(r_pos(1).pdf_by_t,2),3);
    for n = 1:length(r_pos)
      img(:,:,1) = img(:,:,1) + r_pos(n).color(1) .* ones(size(r_pos(n).pdf_by_t)) .* r_pos(n).pdf_by_t.^opt.e;       % set red channel
      img(:,:,2) = img(:,:,2) + r_pos(n).color(2) .* ones(size(r_pos(n).pdf_by_t)) .* r_pos(n).pdf_by_t.^opt.e;       % set green channel
      img(:,:,3) = img(:,:,3) + r_pos(n).color(3) .* ones(size(r_pos(n).pdf_by_t)) .* r_pos(n).pdf_by_t.^opt.e;       % set blue channel
    end % end for over r_pos length
    if(opt.norm_c)
      img = img ./ opt.max_p;
      img(:,:,1) = img(:,:,1) ./ max(max(img(:,:,1)));
      img(:,:,2) = img(:,:,2) ./ max(max(img(:,:,2)));
      img(:,:,3) = img(:,:,3) ./ max(max(img(:,:,3)));
    end
    if(~isempty(r_pos(1).f_bins))
        f_bins = r_pos(1).f_bins;
        bin_centers = r_pos(1).x_vals;
        bin_dx = min(diff(bin_centers));
        bin_starts = bin_centers - bin_dx/2;
        bin_ends = bin_centers + bin_dx/2;
        
        new_img = zeros(size(img,1)+size(f_bins,2)-1, size(img,2), size(img,3));
        next_row = 1;
        f_bins = f_bins';
        for n = 1:size(f_bins,2)
            this_f_bin = f_bins(:,n);
            this_keep = (bin_starts >= this_f_bin(1)  &  bin_ends <= this_f_bin(2));
            this_n_keep = sum(this_keep);
            new_img(next_row:(next_row+this_n_keep-1), :,:) = img(this_keep,:,:);
            next_row = next_row + this_n_keep + 1;
        end
        img = new_img(1:(next_row-2),:,:);
    end
    if(max(max(max(img))) > 1)
      warning('plot_multi_r_pos:too_large_img','The colors going into the composite pdf image are too strong.  Normalizing to max.  Try to monkey w/ the trode_group colors.');
      img = img ./ max(max(max(img)));
    end
    if(~opt.log_scale)
        image([r_pos(1).tstart, r_pos(1).tend],r_pos(1).x_range,img);
    else
        new_img = img.^(1/2);
        img_range = [min(min(min(new_img))), max(max(max(new_img)))];
        new_img = (new_img - img_range(1)) ./ diff(img_range);
        image([r_pos(1).tstart,r_pos(1).tend],r_pos(1).x_range,new_img);
        %image(r_pos(1).x_range,[r_pos(1).tstart,r_pos(1).tend],new_img');
    end
    hold on;
    set(gca,'YDir','normal');

  end
	   
  if(opt.draw_centermarks)
    plot([0 0],[-.1 .1],'w-');
    hold on;
    plot([-0.05 0.05],[0 0],'w-');
  end

  for n = 1:length(r_pos)
    [p_at_mode,r_mode] = max(r_pos(n).pdf_by_t,[],1);
    pos_vec = linspace(r_pos(n).x_range(1),r_pos(n).x_range(2),n_row);
    r_mode = pos_vec(r_mode);
    this_p = r_pos(n).pdf_by_t ./ repmat(sum(r_pos(n).pdf_by_t,1),n_row,1);
    r_mean = sum(repmat(pos_vec',1,n_col) .* this_p  , 1); %'
    r_pos(n).p_at_mode = p_at_mode;
    r_pos(n).mode = r_mode;
    r_pos(n).mean = r_mean;			
	   
    if(opt.draw_p_at_mode)
      plot(ts,p_at_mode.*4,'-','Color',r_pos(n).color);
      hold on;
    end

    if(opt.draw_mode)
      plot(ts,r_mode,'.','Color',r_pos(n).color);
      hold on;
    end

    if(opt.draw_mean)
      plot(ts,r_mean,'-','Color',r_pos(n).color);
      hold on;
    end

    if(opt.draw_rat_pos)
        plot(conttimestamp(pos.lin_filt),...
            pos.lin_filt.data','-','Color',[1 0.25 1],'LineWidth',2);
        hold on;
    end
    
    if(opt.figure_quality)
        set(gca,'FontSize',24);
        set(gcf,'Position',[0 0 1000 670]);
        %ylim([0 2]);
        %xlim([5088.3 5089.5]);
        set(gca,'Color',[0.1 0.1 0.1]);
        set(gcf,'Color',[51 51 51]/255);
    end
    
  end % end for over r_pos length
