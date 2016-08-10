function [h,t,d_pos] = plot_r_pos(r_pos,pos,varargin)

p = inputParser;
p.addParamValue('color',[]);
p.addParamValue('white_background',false);
p.addParamValue('plot_p_at_mode',false);
p.addParamValue('scale_exponent',1);
p.addParamValue('timewin',[]);
p.parse(varargin{:});
e = p.Results.scale_exponent;

p.Results.plot_p_at_mode

if(~isempty(p.Results.timewin))
    ts = linspace(r_pos.tstart,r_pos.tend,size(r_pos.pdf_by_t,2));
    dt = ts(2)-ts(1);
    keep_log = and(ts >= p.Results.timewin(1), ts <= p.Results.timewin(2));
    new_ts = ts(keep_log);
    r_pos.pdf_by_t = r_pos.pdf_by_t(:,keep_log);
    r_pos.tstart = new_ts(1);
    r_pos.tend = new_ts(end);
    ts = new_ts;
end

if(not(isempty(p.Results.color)))
    if(~p.Results.white_background)
    new_pdf = zeros([size(r_pos.pdf_by_t,1),size(r_pos.pdf_by_t,2),3]);
    all_zero = zeros(size(r_pos.pdf_by_t));
   if(strcmp(p.Results.color,'red'))
       new_pdf(:,:,1) = r_pos.pdf_by_t.^e;
   elseif(strcmp(p.Results.color,'green'))
       new_pdf(:,:,2) = r_pos.pdf_by_t.^e;
   elseif(strcmp(p.Results.color,'blue'))
       new_pdf(:,:,3) = (r_pos.pdf_by_t).^e;
   elseif(strcmp(p.Results.color,'gray'))
       new_pdf = repmat(r_pos.pdf_by_t,[1 1 3]).^e;
   end
   r_pos.pdf_by_t = new_pdf;
    end
   
   if(p.Results.white_background)
       new_pdf = ones([size(r_pos.pdf_by_t,1),size(r_pos.pdf_by_t,2),3]);
       if(strcmp(p.Results.color,'red'))
           new_pdf(:,:,2) = new_pdf(:,:,2) - r_pos.pdf_by_t.^e;
           new_pdf(:,:,3) = new_pdf(:,:,3) - r_pos.pdf_by_t.^e;
       elseif(strcmp(p.Results.color,'green'))
           new_pdf(:,:,1) = new_pdf(:,:,1) - r_pos.pdf_by_t.^e;
           new_pdf(:,:,3) = new_pdf(:,:,3) - r_pos.pdf_by_t.^e;
       elseif(strcmp(p.Results.color,'blue'))
           new_pdf(:,:,1) = new_pdf(:,:,1) - r_pos.pdf_by_t.^e;
           new_pdf(:,:,2) = new_pdf(:,:,2) - r_pos.pdf_by_t.^e;
       elseif(any(strcmp(p.Relutls.color,{'gray','grey'}))) % gray can be spelled 2 ways I think
           new_pdf = repmat(1 - r_pos.pdf_by_t,[1 1 3]);
       end
    r_pos.pdf_by_t = new_pdf;
   end
end



h = image([r_pos.tstart,r_pos.tend],r_pos.x_range,(r_pos.pdf_by_t));
set(gca,'YDir','normal');
hold on;
plot(conttimestamp(pos.lin_filt),pos.lin_filt.data,'b.','MarkerSize',1);

if(p.Results.plot_p_at_mode)
    %ax2 = axes('Position',get(gca,'Position'),'YAxisLocation','right');
    disp('In the if statement!!');
    n_row = size(r_pos.pdf_by_t,1);
    n_col = size(r_pos.pdf_by_t,2);
    mean_img = mean(r_pos.pdf_by_t,3);
    sums_cols = sum(mean_img,1);
    norm_col_img = mean_img ./ repmat(sums_cols,n_row,1);
    x_vec = linspace(r_pos.x_range(1),r_pos.x_range(2),n_row);
    x_mat = repmat(x_vec',1,n_col);
    decoded_pos = sum((norm_col_img .* x_mat),1);
    p_at_mode = mean_img(mean_img == repmat(max(mean_img,[],1),size(mean_img,1),1));
    %plot(linspace(r_pos.tstart,r_pos.tend,numel(p_at_mode)),p_at_mode,'w');
    plot(linspace(r_pos.tstart,r_pos.tend,numel(decoded_pos)),decoded_pos,'w');
    t = linspace(r_pos.tstart,r_pos.tend,numel(decoded_pos));
    d_pos = p_at_mode;
end