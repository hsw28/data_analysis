function [score] = compute_line_score(tbins, pbins, pdf, slope, intercept, smooth)
        
    if nargin<6
        smooth = 0;
    end
    
    if ~all( diff( pbins) ) || pbins(1) ~= 1 || pbins(end) ~= numel(pbins)
        error('Pbins should be [1 2 3 ... N]');
    end
    
    if isempty(slope) || isempty(intercept)
        [slope intercept] = est_line_detect(tbins, pbins, pdf);
    end
        
    scores = zeros(size(tbins));
    
    xPts = (1:numel(tbins))';
    yPts = round( slope*tbins + intercept );
    
    evalIdx = yPts>=min(pbins) & yPts<=max(pbins);
    
%     try    
%     
%     catch err
%         disp('Invalid indices, no score calculated');
%         return;
%     end
%     

    pdf(isnan(pdf)) = 0;
    
    if smooth
        pdf = smoothn(pdf, 'kernel' ,'my_kernel', 'my_kernel', [1;1;1], 'normalize', 0);
    end
    
    ind = sub2ind(size(pdf), yPts(evalIdx), xPts(evalIdx));
    scores(evalIdx) = sum(pdf(ind)) ./ numel(ind);   
    score = mean(scores);
end