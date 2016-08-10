function f = sws_example(m)

baseDataPathWake  = [m.basePath,'/d.mat'];
baseDataPathSleep = [m.basePath,'/dSleep.mat'];
if(exist(baseDataPath))
    load baseDataPath;
else
    d = loadData(m,'segment_style','areas');
end
d.trode_groups = m.trode_group_fn('date',m.today,'segment_style','areas');

timewins = example_timewins(m);


end

function twins = example_timewins(m)
    twins = cell(1,2);
    if strContains(m.basePath,'caillou/112812')
        %error('sws_example:112812_not_browsed','not browsed for this data');
        twins = {[],[]};
    end
end