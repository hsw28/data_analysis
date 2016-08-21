function [co co_dist] =  calc_recon_errors(pospdf, tbins, p, varargin)

args.vel_thold = .15;
args.n_boot = 0;
args.boot_percentage = .8;
args.dp = .1;
args = parseArgsLite(varargin,args);



if args.boot_percentage>1 || args.boot_percentage<=0
    error('boot_percentage must be between 0 and 1');
end


posEst = pos_pdf_to_pos_estimate(pospdf, p);

posRec = interp1(p.ts, p.lp, tbins, 'nearest');
posRec(isnan(posRec)) = 0;

posRec = floor(posRec*10)+1;
velRec = interp1(p.ts, p.lv, tbins, 'nearest');
velRec(isnan(velRec)) = 0;

posMat = zeros( numel( min(p.lp):args.dp:max(p.lp) ), numel(tbins));

for i=1:numel(posRec)
    posMat(posRec(i),i) = 1;
end


isMoving = abs(velRec)>.1;
idx = find(isMoving);
co_dist = [];
for i=1:numel(pospdf)
    
    pdf_temp = pospdf{i};
    pdf_temp(:,isnan(pdf_temp(1,:))) = 0;
    co{i} = corr2(posMat(:,idx), pdf_temp(:,idx));
        
    for c = 1:args.n_boot
        rand_idx = randsample(idx,floor(numel(idx)*args.boot_percentage));
        co_dist{i}(c) = corr2(posMat(:,idx), pospdf{i}(:,idx));
    end
end
        
        