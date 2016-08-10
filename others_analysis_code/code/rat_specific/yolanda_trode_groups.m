function trode_groups = yolanda_trode_groups(varargin)

p = inputParser();
p.addParamValue('areas',[]);
p.addParamValue('date','121111');
p.addParamValue('silent',false);
p.addParamValue('segment_style',[]);
p.parse(varargin{:});
opt = p.Results;

n = @(x) str2num(date_ad_to_alpha(x));
d = opt.date;


if( n(d) >= n('112511') && n(d) <= n('121111'))
    if (strcmp(opt.segment_style,'areas'))
        trode_groups{1}.name   = 'CA1';
        trode_groups{1}.trodes = {'11','12','15','16','17','18','19','20','21','22','23','24'};
        trode_groups{1}.color  = [1 0 0];

        trode_groups{2}.name   = 'CA3';
        trode_groups{2}.trodes = {'30','29','28','27','26','25','01','02','03','04','05','06','07','13','14','08','09'};
        trode_groups{2}.color = [0 1 0];

        trode_groups{3}.name   = 'reference';
        trode_groups{3}.trodes = {};
        trode_groups{3}.color = [0 0 1];

        trode_groups{4}.name = 'bad';
        trode_groups{4}.trodes = {'10'};
        trode_groups{4}.color  = [0 0 0];
    elseif(strcmp(opt.segment_style,'ml'))
        trode_groups{1}.name   = 'medial';
        %trode_groups{1}.trodes = {'19','20','21','22','23','24'};
        trode_groups{1}.trodes = {'24','22','23','20'}; % drop some medial that are now too close to lateral
        trode_groups{1}.color  = [1 0 0];

        trode_groups{2}.name   = 'mid';
        %trode_groups{2}.trodes = {'15','16','17','18'};
        trode_groups{2}.trodes = {'17','18'}; % Send some mid to lateral
        trode_groups{2}.color  = [0 1 0];
        
        trode_groups{3}.name   = 'lateral';
        %trode_groups{3}.trodes = {'11','12'};
        trode_groups{3}.trodes = {'15','16','11','12'}; %Bring in some more mid-level
        trode_groups{3}.color  = [0 0 1];
        
        trode_groups{4}.name   = 'CA3';
        trode_groups{4}.trodes = {'30','29','28','27','26','25','01','02','03','04','05','06','07','13','14','08','09'};
        trode_groups{4}.color = [0 0.5 0];

        trode_groups{5}.name   = 'reference';
        trode_groups{5}.trodes = {};
        trode_groups{5}.color = [0 0 1];

        trode_groups{6}.name = 'bad';
        trode_groups{6}.trodes = {'10'};
        trode_groups{6}.color  = [0 0 0];
    else
        error('yolanda_trode_groups:unknown_style',['Unknown style: ', opt.segment_style]);
    end
end


if( n(d) == n('120811') || n(d) == n('112511') || n(d) == n('120711')) % 8 and 9 have gotten into CA1 on 120811 120711 and 112511
    if(strcmp(opt.segment_style,'areas'))
        trode_groups{1}.trodes = {'11','12','15','16','17','18','19','20','21','22','23','24','08','09'};
        trode_groups{2}.trodes = {'30','29','28','27','26','25','01','02','03','04','05','06','07','13','14'};
    elseif(strcmp(opt.segment_style,'ml'))
        %trode_groups{3}.trodes = {'11','12','08','09'};
        trode_groups{3}.trodes = {'11','12','08','09','15','16'}; % Bringin some mids into lateral
        trode_groups{4}.trodes = {'30','29','28','27','26','25','01','02','03','04','05','06','07','13','14'};
    else
        error('yolanda_trode_groups:unknown_style',['Unknown style: ', opt.segment_style]);
    end
end

if(n(d) > n('121111'))
  error('need to find trode groups for Sept 14th onward.');

end

if(n(d) < n('112511') || n(d) > n('121111'))
    trode_groups = 0;
    if(~opt.silent)
        error('yolanda_trode_groups:bad_date',['No data for the date ', d]);
    end
end
