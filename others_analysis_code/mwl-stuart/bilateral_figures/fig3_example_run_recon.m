
function fig3_example_run_recon(pdf1, pdf2, t, ax)
   
    im = pdf1;
    im(:,:,2) = pdf2;
    im(:,:,3) = 0;
    
    
    if isempty(t)
        t = 1:size(pdf1,2);
    end
    
    imagesc(t, 0:.1:3, im, 'Parent', ax);
    
    set(ax,'YDir', 'normal');
    
end
