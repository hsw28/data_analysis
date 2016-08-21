function [mi mi_var entropyPos entropyRecon] =  calc_recon_mi(pospdf, tbins, pbins, p, varargin)

args.vel_thold = .15;
args.n_boot = 0;
args.boot_percentage = .8;
args = parseArgsLite(varargin,args);

if args.boot_percentage>1 || args.boot_percentage<=0
    error('boot_percentage must be between 0 and 1');
end
% 
% 
% laps = exp_lapify(p);
% 
% laps = laps(laps(:,1)>=tbins(1),:);
% 
% idx = false(size(p.ts));
% for i=1:size(laps,1)
%     ind = p.ts>=laps(i,1) & p.ts<=laps(i,2);
%     idx(ind) = true;
% end
% 
% p.lv(~idx) = 0;
%dt = mean(diff(tbins));
posEst = pos_pdf_to_pos_estimate(pospdf, tbins, pbins, p);


posRec = interp1(p.ts, p.lp, tbins, 'nearest');
posRec(isnan(posRec)) = 0;
posRec = floor(posRec*10)/10;
velRec = interp1(p.ts, p.lv, tbins, 'nearest');
velRec(isnan(velRec)) = 0;

isMoving = abs(velRec)>.1;



%the MI calculation automatically bins on integers, so if posRec and posEst
%are not multiplied by 10 then only 4 bins will be used, after
%multiplication there are ~30 bins with each bin representing a position
%bin on the track
for i=1:numel(pospdf)
   
    a = posRec(isMoving);
    b = posEst{i}(isMoving);
    
    pJoint = hist3([a(:), b(:)], {pbins, pbins});
    pJoint = pJoint ./ nansum(pJoint(:));
           
    %mi(i) = mutualinfo(posEst{i}(idx)*10, posRec(idx)*10);
    [mi(i) mi_var(i)] = mutualinfo_fk(pJoint, sum(isMoving), 2);
    entropyPos(i)   = entropy(a*10);
    entropyRecon(i) = entropy(b*10);
   
end
        
        