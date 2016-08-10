function fig = easycontdisp(cdat,time,varargin)

p = inputParser;
p.addParamValue('reshape_size',[],@(x) (numel(x)==2));
p.addParamValue('data_range',[],@(x) (numel(x)==2));
p.parse(varargin{:});
rs = p.Results.reshape_size;
dr = p.Results.data_range;

timestamp = conttimestamp(cdat);
tdifs = abs(time - timestamp);
closest_ind = find(tdifs == min(tdifs));

if(numel(closest_ind)>1)
    disp('Warning: easycontdisp was given a time (',num2str(time),') straddling 2 timestamps');
    disp('Choosing earlier timestamp');
    closest_ind = closest_ind(1);
end

this_dat = cdat.data(closest_ind,:);

if(not(isempty(dr)))
    this_dat = (this_dat-dr(1))./(dr(2)-dr(1)).*100; % how many range-units above the min is our data?
end

if(not(isempty(rs)))
    if((rs(1)*rs(2)) == numel(this_dat))
        this_dat = reshape(this_dat,rs(1),rs(2));
    else
        disp('Warning: reshape dims do not multiply to numel(series)');
    end
end

fig = image(this_dat);
colormap(hot(100));
title(['Name: ' cdat.name, 'Time: ', num2str(time)]);
