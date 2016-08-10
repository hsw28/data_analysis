function quick_plot2(eeg1,chan1,eeg2,chan2,varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('scale',1);
p.addParamValue('offset',[]);
p.parse(varargin{:});
opt = p.Results;

if(~isempty(opt.timewin))
    eeg1 = contwin(eeg1,opt.timewin);
    eeg2 = contwin(eeg2,opt.timewin);
end

if(~isempty(opt.offset))
    eeg2.data = eeg2.data + opt.offset;
end

ts1 = conttimestamp(eeg1);
ts2 = conttimestamp(eeg2);

plot(ts1,eeg1.data(:,chan1));
hold on;
plot(ts2,eeg2.data(:,chan2)*scale,'g');