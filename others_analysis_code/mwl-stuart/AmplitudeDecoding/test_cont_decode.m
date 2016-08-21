

pdc = poisson_decode_cont(amps, exp15.run.pos, 't_range', trange);

drange = [4928 4937];

dt = .25;
cur_time = drange(1);
est = [];
i = 0;
while cur_time < drange(end)
    i = i+1;
    spikes = {};
    for i=1:numel(amps)
       ts = amps{i}(:,5);
       ind = ts>=cur_time & ts<cur_time+dt;
       spikes{i} = amps{i}(ind,1:4);
    end
    
    est(:,i) = pdc_decode(pdc, spikes, dt);
    cur_time = cur_time + dt;
   
end



imagesc(est);



%% Compute Distances
kw = 10;

train = tra{1}(:,1:4)';
deco = dec{1}(:,1:4)';
tic;
d = sqrt(bsxfun(@plus,dot(train,train,1)',dot(deco,deco,1))-2*train'*deco); 
toc;
d(d>4*kw) = Inf;
%% Convert distances to weights
tic;
w = 1/sqrt(2*pi*kw^2) .* exp( - ( d3.^2) / (2*kw^2) );
toc;
%%

p = tra{1}(:,6);
t = dec{1}(:,5);
ct = drange(1);
dt = .25;
est = []; 
p = round(p*100);
pbins = 1:max(p2);
tbins = [];
tbins = drange(1):dt:drange(end);

%est = ones(numel(pbins), numel(tbins))/numel(pbins);

 
%P = 0;
%   obj.Pstim = position occupancy
%   obj.mu = average multi unit rate
%   t = total measurement time
%   nspikes = total number of spikes for that tetrode
%
% for k=1:numel(test_response)
%     %compute P(stimulus|spike,response)
%     %tmp = amp_decode4_c(bsxfun(@rdivide,obj.spike_response{k},wr), bsxfun(@rdivide,obj.spike_stimulus{k},ws), bsxfun( @rdivide, test_response{k},wr), bsxfun(@rdivide,obj.grid,ws), obj.response_kernel_type_data, obj.response_kernel_width_data, obj.stimulus_kernel_type_data, obj.stimulus_kernel_width_data );
% 
%     tmp = amp_decode4_c( obj.spike_response{k}, obj.spike_stimulus{k}, test_response{k}, obj.grid, obj.response_kernel_type_data, obj.response_kernel_width_data, obj.stimulus_kernel_type_data, obj.stimulus_kernel_width_data );
% 
%     %tmp = prod(tmp,1)./(obj.Pstim.^nspikes(k));
% 
% 
%     tmp = sum(log(tmp),1) - nspikes(k).*log(obj.Pstim);
% 
%     %tmp = tmp.*exp(-dt.*obj.mu(k).*obj.Pstimspike{k}./obj.Pstim);
%     tmp = tmp - dt.*obj.mu(k).*obj.Pstimspike{k}./obj.Pstim;
% 
%     %tmp = tmp./nansum(tmp(:));
%     P = P + tmp;
% 
% 
%     %tmp = bsxfun( @rdivide, tmp, nansum(tmp,2) );
%     %P=P+nansum(log( tmp ),1 );
%     %P=P-nspikes(k).*log(obj.Pstim) - dt.*obj.mu(k).*obj.Pstimspike{k}./obj.Pstim;
% end
% 

t_elapse = drange(end) - drange(1);
ns = size(trange,1);
mu = ns ./ t_elapse;
stim = smoothn(histc(round(pos*100)', pbins),1);
spikestim = smoothn(histc(p,pbins),1);

j = 0;

while ct<=drange(end)
    P = 0;
    j = j+1;
    disp(j);
    ind = find(t>=ct & t<ct+dt);

    e = accumarray(p2,0);
    for i = 1:numel(ind)
        h = accumarray(p2,w(:,ind(i)));
        e(:,i) = h;
    end
    tmp = e;
    tmp = sum(log(tmp),2) - nspikes.*log(stim);
    tmp = tmp - dt .* mu .* spikestim ./ stim;
    
    P = P + tmp;
    
    P = exp(P-nanmax(P));
    P = P./nansum(P(:));
    
    est(:,end+1) = P;
    
    ct = ct+dt;   
  

end





