function [c tbins] = recon_corr(pdf1, pdf2, varargin)
args.ts = [];
args.te = [];
args.win_size = 1;


args = parseArgsLite(varargin,args);


if ~any(size(pdf1) == size(pdf2))
    error('PDFS must be the same size');
end


data_len = size(pdf1,2);
cur_ind = 1;
c = [];
n_step = floor(data_len/args.win_size)+1;
count = 0;
w_bar = my_waitbar(0);
warning off;


while cur_ind + args.win_size < data_len
    ind = cur_ind:cur_ind+args.win_size-1;
    c(end+1) = corr2(pdf1(:,ind,1), pdf2(:,ind,2));
    
    count = count+1;
  
    my_waitbar(count/n_step,w_bar);
    cur_ind = cur_ind + args.win_size;    
end

%c(isnan(c)) = 0;
warning on;
close(w_bar);

tbins = NaN;
if ~isempty(args.ts) &&  ~isempty(args.te)
    tbins = linspace(args.ts, args.te, count);
end