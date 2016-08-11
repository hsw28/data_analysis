function trode_groups = morpheus_trode_groups(varargin)

p = inputParser();
p.addParamValue('segment_style','st',(@(x) any(strcmp(x,{'st','ml','pd','areas'}))));
p.addParamValue('date',[]);
p.addParamValue('silent',false);
p.parse(varargin{:});
opt = p.Results;

n = @(x) str2num(date_ad_to_alpha(x));
d = opt.date;

if(strcmp(opt.segment_style,'st'))

    trode_groups{1}.name   = 'septal';
    trode_groups{1}.trodes = {'02','03','24','23','20','21'};
    trode_groups{1}.color  = [1 0 0];
    
    trode_groups{2}.name   = 'mid';
    trode_groups{2}.trodes = {'05','16','17','06','07','14'};
    trode_groups{2}.color  = [0 1 0];
    
    trode_groups{3}.name   = 'temporal';
    trode_groups{3}.trodes = {'08','11','13','10','12','15'};
    trode_groups{3}.color  = [0 0 1];

end

if(strcmp(opt.segment_style,'ml'));
    %Medial-lateral
    trode_groups{1}.name   = 'medial';
    trode_groups{1}.trodes = {'02','03','24','23','20','21'};
    trode_groups{1}.color = [1 0 0];
    
    trode_groups{2}.name   = 'mid';
    trode_groups{2}.trodes = {'05','16','17','06','15','14'};
    trode_groups{2}.color = [0 1 0];
    
    trode_groups{3}.name   = 'lateral';
    trode_groups{3}.trodes = {'08','11','13','10','12','07'};
    trode_groups{3}.color = [0 0 1];
end

if(strcmp(opt.segment_style,'pd'))
    %Proximal-distal
    trode_groups{1}.name   = 'proximal';
    trode_groups{1}.trodes = {'02','03','05','06','07','08'};
    trode_groups{1}.color = [1 0 0];
    
    trode_groups{2}.name   = 'mid';
    trode_groups{2}.trodes = {'24','16','14','11','10'};
    trode_groups{2}.color = [0 1 0];
    
    trode_groups{3}.name   = 'distal';
    trode_groups{3}.trodes = {'23','21','20','17','15','13','12'};
    trode_groups{3}.color = [0 0 1];
    
end

if(strcmp(opt.segment_style,'areas'))
   trode_groups{1}.name = 'CA1';
   trode_groups{1}.trodes = {'02','03','05','06','07','08','24','16','14','11','10','23','21','20','17','15','13','12','18'};
   trode_groups{1}.color = [1 0 0];
   
   trode_groups{2}.name = 'bad';
   trode_groups{2}.trodes = {};
   trode_groups{2}.color = [1 0 1];
end

if(strcmp(opt.segment_style,'many'))
    % Super-tight groups
    trode_groups{1}.trodes = {'01','02','03'};
    trode_groups{2}.trodes = {'21','23','24'};
    trode_groups{3}.trodes = {'04','22','20'};
    trode_groups{4}.trodes = {'05','19','18'};
    trode_groups{5}.trodes = {'06','16','17'};
    trode_groups{6}.trodes = {'07','14','15'};
    trode_groups{7}.trodes = {'08','11','13'};
    trode_groups{8}.trodes = {'09','10','12'};

    for n = 1:8
        trode_groups{n}.name  = ['group', num2str(n)];  
        trode_groups{n}.color = [(8-n)/8, (n)/8, 0];
    end
end

if(strcmp(opt.segment_style,'two'))   

    trode_groups{1}.trodes = {'02','03','24','23','20','21'};
    trode_groups{2}.trodes = {'08','11','13','10','12','15','06','07','14'};
    trode_groups{1}.color = [1 0 0];
    trode_groups{2}.color = [0 1 0];

end
