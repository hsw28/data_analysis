function trode_groups = blue_trode_groups(varargin)

p = inputParser();
p.addParamValue('segment_style',[]);
p.addParamValue('date','021313');
p.addParamValue('silent',false);
p.parse(varargin{:});
opt = p.Results;

n = @(x) str2num(date_ad_to_alpha(x));
d = opt.date;

if(strcmp(opt.segment_style,'areas'))
    if( n(d) >= n('021313') && n(d) <= n('023113'))
        trode_groups{1}.name   = 'THAL';
        trode_groups{1}.trodes = {'23','24','25','26','27','28','29'};
        trode_groups{1}.color  = [1 0 0];


        trode_groups{2}.name   = 'RSC';
        trode_groups{2}.trodes = {'11','13','14','15','16','17','18','19','21','22','18arte','17arte'};
        trode_groups{2}.color = [0 1 0];

        trode_groups{3}.name   = 'CA1';
        trode_groups{3}.trodes = {'01','02','03','04','05','06','08','10'};
        trode_groups{3}.color = [0 0 1];

        trode_groups{4}.name = 'bad';
        trode_groups{4}.trodes = {'09','12','20','30'};
        trode_groups{4}.color = [1 0.5 0.5];

        trode_groups{5}.name = 'reference';
        trode_groups{5}.trodes = '07';
        trode_groups{5}.color  = [0 0 0];

    end

    if( n(d) >= n('030113') && n(d) <= n('032713'))
        trode_groups{1}.name   = 'THAL';
        trode_groups{1}.trodes = {'23','24','25','26','27','28','29'};
        trode_groups{1}.color  = [1 0 0];


        trode_groups{2}.name   = 'RSC';
        trode_groups{2}.trodes = {'11','13','14','15','16','17','18','19','21','22','18arte','17arte'};
        trode_groups{2}.color = [0 1 0];

        trode_groups{3}.name   = 'CA1';
        trode_groups{3}.trodes = {'01','02','03','04','05','06','07','08','10'};
        trode_groups{3}.color = [0 0 1];

        trode_groups{4}.name = 'bad';
        trode_groups{4}.trodes = {'20'}';
        trode_groups{4}.color = [1 0.5 0.5];

        trode_groups{5}.name = 'reference';
        trode_groups{5}.trodes = '30';
        trode_groups{5}.color  = [0 0 0];

        trode_groups{6}.name = 'chew';
        trode_groups{6}.trodes = {'09','12'};
        trode_groups{6}.color = [0 0 0];

    end

    if (n(d) >= n('031213') && n(d) <= n('032713'))
        trode_groups{5}.trodes = {'20'};

        trode_groups{4}.trodes = {'30'};
    end

    if ( n(d) == n('032813') )
        trode_groups{1}.name   = 'THAL';
        trode_groups{1}.trodes = {'23','24','25','26','27','28','29'};
        trode_groups{1}.color  = [1 0 0];


        trode_groups{2}.name   = 'RSC';
        trode_groups{2}.trodes = {'11','13','14','15','16','17','18','19','21','22','18arte','17arte'};
        trode_groups{2}.color = [0 1 0];

        trode_groups{3}.name   = 'CTX';
        trode_groups{3}.trodes = {'01','03','04','05','06','08','10'};
        trode_groups{3}.color = [1 0 1];

        trode_groups{4}.name = 'CA1';
        trode_groups{4}.trodes = {'02'};
        trode_groups{4}.color = [0 0 1];

        trode_groups{5}.name = 'bad';
        trode_groups{5}.trodes = {'07','30'}';
        trode_groups{5}.color = [1 0.5 0.5];

        trode_groups{6}.name = 'chew';
        trode_groups{6}.trodes = {'09','12'};
        trode_groups{6}.color = [0 0 0];

        trode_groups{7}.name = 'reference';
        trode_groups{7}.trodes = {'20'};
        trode_groups{7}.color = [0 0 0];

    end

    if( n(d) > n('032813') && n(d) <= n('040913'))

        trode_groups{1}.name   = 'CTX';
        trode_groups{1}.trodes = {'25','26','27','28', '01','03','04','05','06','08','10'};
        trode_groups{1}.color  = [1 0 1];

        trode_groups{2}.name   = 'RSC';
        trode_groups{2}.trodes = {'11','13','14','15','16','17','18','19','21','22','18arte','17arte'};
        trode_groups{2}.color = [0 1 0];

        trode_groups{3}.name = 'CA1';
        trode_groups{3}.trodes = {'02'};
        trode_groups{3}.color = [0 0 1];

        trode_groups{4}.name = 'THAL';
        trode_groups{4}.trodes = {'23','24','29'};
        trode_groups{4}.color = [1, 0, 0];

        trode_groups{5}.name = 'bad';
        trode_groups{5}.trodes = {'07','30'}';
        trode_groups{5}.color = [1 0.5 0.5];

        trode_groups{6}.name = 'chew';
        trode_groups{6}.trodes = {'09','12'};
        trode_groups{6}.color = [0 0 0];

        trode_groups{7}.name = 'reference';
        trode_groups{7}.trodes = {'20'};
        trode_groups{7}.color = [0 0 0];

    end
    else
        error('blue_trode_groups:no_segment_style_data',...
            ['haven''t written group data for segment_style: ', ...
            opt.segment_style]);
end


if(n(d) < n('021313') || n(d) > n('040913'))
    trode_groups = 0;
    if(~opt.silent)
        error('blue_trode_groups:bad_date',['No data for the date ', d]);
    end
end
