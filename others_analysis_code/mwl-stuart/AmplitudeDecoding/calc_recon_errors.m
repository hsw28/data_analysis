function [errors me me_dist me_sem posRec velRec isMoving] =  calc_recon_errors(pospdf, tbins, pbins, p, varargin)

args.vel_thold = .15;
args.n_boot = 0;
args.boot_percentage = .8;
args = parseArgsLite(varargin,args);

if args.boot_percentage>1 || args.boot_percentage<=0
    error('boot_percentage must be between 0 and 1');
end


dt = mean(diff(tbins));
posEst = pos_pdf_to_pos_estimate(pospdf, tbins, pbins, p);

warning off;
posRec = interp1(p.ts, p.lp, tbins, 'nearest');
warning on;

posRec(isnan(posRec)) = 0;
%posRec = floor(posRec*10)/10;
velRec = interp1(p.ts, p.lv, tbins, 'nearest');
velRec(isnan(velRec)) = 0;

isMoving = abs(velRec)>.1;
idx = find(isMoving);

for i=1:numel(pospdf)
  
    if numel(posEst{i})>numel(posRec)
        posRec = [posRec posRec(end)];
    elseif numel(posRec)>numel(posEst{i})
        posEst{i} = [posEst{i} posEst{i}(end)];
    end

    errors{i} = abs(posEst{i} - posRec);
    errors{i}(~isMoving) = NaN;
       
    me(i) = nanmedian(errors{i});
    me_dist{i} = zeros(args.n_boot,1);    
    
    for c = 1:args.n_boot
        rand_idx = randsample(idx,floor(numel(idx)*args.boot_percentage));
        me_dist{i}(c) = median(errors{i}(rand_idx));
    end
    
    me_sem(i) = std(me_dist{i})/sqrt(args.n_boot);
end
        
        