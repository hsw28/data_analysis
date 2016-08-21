function pdf = pdc_decode(pdc, spikes, dt)
if ~iscell(spikes)
    spikes = {spikes}; 
end
if numel(spikes)~=numel(pdc.amps)
    error('Invalide spike array');
end

pdf = 0;
for i=1:numel(spikes)
    
    s = spikes{i}(:,1:4)';
    
    if numel(s>0)
       
        p = pdc.pos{i};
        t = pdc.amps{i}(:,1:4)';
        d = sqrt(bsxfun(@plus,dot(t,t,1)',dot(s,s,1))-2*t'*s); 

        w = 1/sqrt(2*pi*pdc.kw^2) .* exp( - ( d.^2) / (2*pdc.kw^2) );
        for j = 1:size(w,2)
            
            [h bins] = histc(p, pdc.pbins);    
            tmp = accumarray(bins,w(:,j), [numel(pdc.pbins),1]);
            
            tmp = sum(log(tmp),2)' - pdc.nSpikes{i}.*log(pdc.stim);
            tmp = tmp - dt .* pdc.mu{i} .* pdc.spikestim{i} ./ pdc.stim;
            
            pdf = pdf + tmp;
        end
    end
    
end

pdf = exp(pdf-nanmax(pdf));
pdf = pdf./nansum(pdf(:));



% pdc = 
% 
%          amps: {1x17 cell}  % amplitudes for each spike
%            kw: 10
%            mu: {1x17 cell}
%       nSpikes: {1x17 cell}
%         pbins: [1x310 double]
%           pos: {1x17 cell} % positions for each spike
%     spikestim: {1x17 cell} %
%          stim: [1x310 double]

% spikes = 
%     cell array of nx4 matrices, with each sub value containing n spikes 
