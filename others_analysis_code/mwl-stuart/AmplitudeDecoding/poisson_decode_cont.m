function d =  poisson_decode_cont(data,pos, varargin)
args.bw = 1; %in centimeters
args.kw = 10;
args.t_range = [0 inf];

args = parseArgsLite(varargin,args);

ind = pos.ts>=args.t_range(1) & pos.ts<args.t_range(end);
p = round(pos.lp(ind)*100/args.bw); %% EVERYTHING IN CENTIMETERS!!!!!!!!!!!!!!!
d.pbins = min(p):max(p);

if ~iscell(data)
    data = {data};
end

for an = 1:numel(data);
    ind = data{an}(:,5)>=args.t_range(1) & data{an}(:,5)<args.t_range(end);
    d.amps{an} = data{an}(ind,1:4);
    d.pos{an} = round(data{an}(ind,6) * 100);
    d.spikestim{an} = histc(d.pos{an}, d.pbins)';
    d.spikestim{an} = smoothn(d.spikestim{an},1);
    d.nSpikes{an} = sum(ind);
    d.mu{an} =  d.nSpikes{an} / (args.t_range(end) - args.t_range(1));
end


d.stim = smoothn(histc(p, d.pbins),1);
d.kw = args.kw;
d = orderfields(d);

    




end
