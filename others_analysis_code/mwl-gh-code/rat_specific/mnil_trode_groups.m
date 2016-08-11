function trode_groups = mnil_trode_groups(varargin)

p = inputParser();
p.addParamValue('date',[]);
p.addParamValue('segment_style',[]);
p.parse(varargin{:});
opt = p.Results;

n = @(x) str2num(date_ad_to_alpha(x));
d = opt.date;

if(strcmp(opt.segment_style,'st'))
    
    trode_groups{1}.trodes = {'18','12','01','17','11','09'}; 
    trode_groups{1}.name = 'septal';
    trode_groups{1}.color = [1 0 0];
    
    trode_groups{2}.name = 'mid';
    trode_groups{2}.trodes = {'02','03','08','10','15','07'};
    trode_groups{2}.color = [0 ,1,0];
    
    trode_groups{3}.name = 'temporal';
    trode_groups{3}.trodes = {'16','04','05','14','13','06'};
    trode_groups{3}.color = [0 0 1];

elseif(strcmp(opt.segment_style,'ml') || isempty(opt.segment_style))
    
    trode_groups{1}.name = 'medial';    
    trode_groups{1}.trodes = {'18','12','01','17','11'};
    trode_groups{1}.color = [1 0 0];
    
    trode_groups{2}.name = 'mid';
    trode_groups{2}.trodes = {'16','02','09','03','08','10','15'};
    trode_groups{2}.color = [0 ,1,0];
    
    trode_groups{3}.name = 'lateral';
    trode_groups{3}.trodes = {'07','04','05','14','13','06'};
    trode_groups{3}.color = [0 0 1];
    
end
