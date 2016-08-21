function [mi mi_var mi_dist mi_sem] =  calc_recon_mi2(pospdf, tbins, pbins, p, varargin)

args.vel_thold = .15;
args.n_boot = 0;
args.boot_percentage = .8;
args = parseArgsLite(varargin,args);

if args.boot_percentage>1 || args.boot_percentage<=0
    error('boot_percentage must be between 0 and 1');
end

dt = mean(diff(tbins));



laps = exp_lapify(pos);

% filter laps based on decoding range
laps = laps(laps(:,1)>=input.d_range(1),:);


posEst = pos_pdf_to_pos_estimate(pospdf, tbins, pbins, p);

posRec = interp1(p.pts, p.lp, tbins, 'nearest');
posRec(isnan(posRec)) = 0;
posRec = floor(posRec*10)/10;
velRec = interp1(p.pts, p.lv, tbins, 'nearest');
velRec(isnan(velRec)) = 0;

isMoving = abs(velRec)>.1;



    

idx = find(isMoving);



%the MI calculation automatically bins on integers, so if posRec and posEst
%are not multiplied by 10 then only 4 bins will be used, after
%multiplication there are ~30 bins with each bin representing a position
%bin on the track
for i=1:numel(pospdf)
   
    a = posRec(isMoving);
    b = posEst{i}(isMoving);
    
    pJoint = hist3([a(:), b(:)], [numel(pbins) numel(pbins)]);
    pJoint = pJoint ./ nansum(pJoint(:));
           
    %mi(i) = mutualinfo(posEst{i}(idx)*10, posRec(idx)*10);
    [mi(i) mi_var(i)] = mutualinfo_fk(pJoint, numel(posRec), 2);
    mi_dist{i} = zeros(args.n_boot,1);    
    for c = 1:args.n_boot
        rand_idx = randsample(idx,floor(numel(idx)*args.boot_percentage));
        mi_dist{i}(c) = mutualinfo(posEst{i}(rand_idx), posRec(rand_idx));
    end
    mi_sem(i) = std(mi_dist{i})/sqrt(args.n_boot);
end
        
        