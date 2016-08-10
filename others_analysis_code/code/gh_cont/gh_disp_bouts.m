function fig = gh_disp_bouts(bouts,varargin)

p = inputParser();
p.addParamValue('cdat',[]);
p.addParamValue('chan_ind',1);
p.addParamValue('view_dt',0.05);
p.parse(varargin{:});
cdat = p.Results.cdat;
chan_ind = p.Results.chan_ind;
view_dt = p.Results.view_dt;


min_time = [];
max_time = [];
if(not(iscell(bouts)))
    n_bout_lists = 1;
    bouts_cell{1} = bouts;
    bouts = bouts_cell;
    min_time = min(bouts{1});
    max_time = max(bouts{1});
else
    n_bout_lists = numel(bouts);
    for j = 1:n_bout_lists
        min_time = min([min_time,min(min(bouts{j}))]);
        max_time = max([max_time,max(max(bouts{j}))]);
    end
    bouts_cell = bouts;
end

view_y = [0 1];

if(not(isempty(cdat)))
    timestamp = conttimestamp(cdat);
    dat = cdat.data(:,chan_ind);
    this_bouts = bouts{chan_ind};
    view_dt = 1/cdat.samplerate;
    view_y = [cdat.datarange(chan_ind,1),cdat.datarange(chan_ind,2)];
    min_time = min(timestamp);
    max_time = max(timestamp);
else
    timestamp = [min_time:view_dt:max_time];
end

min(timestamp);
max(timestamp);

%blocks = zeros(n_bout_lists,numel(timestamp));

%for j = 1:n_bout_lists
%    this_bouts = bouts{j};n_bout_lists:1
%    size(this_bouts)
%    for i = 1:size(this_bouts,1)
%        blocks(j,(timestamp >= this_bouts(i,1)) & (timestamp <= this_bouts(i,2))) = 5;
%    end
%end

for j = 1:n_bout_lists
    x = n_bout_lists + 1 -j;
    this_bouts = bouts{x};
    for i = 1:size(this_bouts,1)
        if(x==1)
            fc = 'blue';
        else
            fc = 'red';
        end
        %i
        %x
        %this_bouts(i,:)
        rectangle('Position',[this_bouts(i,1),x-1/2,diff(this_bouts(i,:)),1],'FaceColor',fc,'LineStyle','none');
        hold on
    end
end

%fig = image([min_time,max_time],view_y,blocks);

if(not(isempty(cdat)))
    hold on;
    plot(timestamp,dat);
end