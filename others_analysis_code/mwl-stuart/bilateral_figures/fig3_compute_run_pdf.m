
function [pdf1, pdf2, isMoving] =  fig3_compute_run_pdf(r,p)

    t = r(1).tbins;    
    vel = interp1(p.ts,  p.lv, t, 'nearest');
    
    isMoving = abs(vel)>.15;
    
    pdf1 = r(1).pdf(:, isMoving,:);
    pdf1(:,:,2) = pdf1(:,:,1);
    
    pdf2 = r(2).pdf(:, isMoving,:);
    tmp = pdf2(:,:,2);
    pdf2(:,:,2) = pdf2(:,:,3);
    pdf2(:,:,3) = tmp;
    
    
end