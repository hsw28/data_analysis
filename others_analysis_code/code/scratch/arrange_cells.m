function sdat = arrange_cells(sdat)

group1 = {'02','03','04','05','06','07','08','09'};
group2 = {'01','24','22','19','16','14','11','10','23','21','20','18','17','15','13','12'};

set1 = [];
set2 = [];

for n = 1:numel(sdat.clust)
    if(any(strcmp(group1,sdat.clust{n}.comp)))
        set1 = [set1,n];
    end
    if(any(strcmp(group2,sdat.clust{n}.comp)));
        set2 = [set2,n];
    end
end

sdat = sdatslice(sdat,'index',[set1,set2]);