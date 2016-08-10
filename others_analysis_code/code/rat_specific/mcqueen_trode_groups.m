function trode_groups = mcqueen_trode_groups(varargin)

p = inputParser();
p.addParamValue('areas',[]);
p.addParamValue('date','090513');
p.addParamValue('silent',false);
p.parse(varargin{:});
opt = p.Results;

n = @(x) str2num(date_ad_to_alpha(x));
d = opt.date;

if( n(d) >= n('081513') && n(d) <= n('090513'))
    trode_groups{1}.name   = 'CTX';
    trode_groups{1}.trodes = {'24','25','26','27','29','30'};
    trode_groups{1}.color  = [1 0 0];


    trode_groups{2}.name   = 'RSC';
    trode_groups{2}.trodes = {'12','13','14','15','15k','16','17','18','20','21','21arte','22','23'};
    trode_groups{2}.color = [0 1 0];

    trode_groups{3}.name   = 'HPC';
    trode_groups{3}.trodes = {'01','02','03','04','05','06','07','08','09','10','11'};
    trode_groups{3}.color = [0 0 1];

    trode_groups{4}.name = 'reference';
    trode_groups{4}.trodes = {'28','19'};
    trode_groups{4}.color  = [0 0 0];

    trode_groups{5}.name = 'eeg';
    trode_groups{5}.trodes = {'29sk','20sk','26sk','25sk','28sk','16sk'};
    trode_groups{5}.color = [0.6 0.6 0.6];

    trode_groups{6}.name = 'emg';
    trode_groups{6}.trodes = 'emg';
    trode_groups{6}.color = [1 0.4 0.4];

end

if(n(d) >= n('091413'))
  error('need to find trode groups for Sept 14th onward.');

end

if(n(d) < n('081413') || n(d) > n('090513'))
    trode_groups = 0;
    if(~opt.silent)
        error('mcqueen_trode_groups:bad_date',['No data for the date ', d]);
    end
end
