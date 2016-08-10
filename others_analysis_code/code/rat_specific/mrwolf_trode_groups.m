function trode_groups = morpheus_trode_groups(varargin)

if(nargin == 0)
    grp = 'st';
else
    grp = varargin{1};
end

if(strcmp(grp,'st'))
trode_groups{1}.trodes = {'06','05','04','03','07','02','08','01'};
trode_groups{2}.trodes = {'09','29','10','12','28','18','27','13'};
trode_groups{3}.trodes = {'24','25','15','21','23','16','22','19'};
trode_groups{1}.color = [1 0 0];
trode_groups{2}.color = [0 1 0];
trode_groups{3}.color = [0 0 1];
end

if(strcmp(grp,'ml'));
%Medial-lateral
trode_groups{1}.trodes = {'02','03','24','23','20','21'};
trode_groups{2}.trodes = {'05','16','17','06','15','14'};
trode_groups{3}.trodes = {'08','11','13','10','12','07'};
trode_groups{1}.color = [1 0 0];
trode_groups{2}.color = [0 1 0];
trode_groups{3}.color = [0 0 1];
end

if(strcmp(grp,'pd'))
%Proximal-distal
trode_groups{1}.trodes = {'02','03','05','06','07','08'};
trode_groups{2}.trodes = {'24','16','14','11','10'};
trode_groups{3}.trodes = {'23','21','20','17','15','13','12'};
trode_groups{1}.color = [1 0 0];
trode_groups{2}.color = [0 1 0];
trode_groups{3}.color = [0 0 1];
end

if(strcmp(grp,'many'))
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
	  trode_groups{n}.color = [(8-n)/8, (n)/8, 0];
end
end

if(strcmp(grp,'two'))   
trode_groups{1}.trodes = {'02','03','24','23','20','21'};
trode_groups{2}.trodes = {'08','11','13','10','12','15','06','07','14'};
trode_groups{1}.color = [1 0 0];
trode_groups{2}.color = [0 1 0];
end
