function [matrices radon_results allvec allgood05 allgood01] = SWRreplay_wshuff(SWRstartend, pos, clusters, tdecode, num_of_sims)

%decodes replay in SWR and provides only events that cross threshold in shufflee sims, including
%SWRreplay_columnshuff and SWRreplay_unitIDshuff


[matrices radon_results allvec] = SWRreplay(SWRstartend, pos, clusters, tdecode);
monte_unit = SWRreplay_unitIDshuff(SWRstartend, pos, clusters, tdecode, num_of_sims);
monte_column = SWRreplay_columnshuff(SWRstartend, pos, clusters, tdecode, num_of_sims);

temp_unit = find([radon_results(:,2),monte_unit(:,1)]' == max([radon_results(:,2),monte_unit(:,1)]'));
unitgood05 = (find(rem(temp_unit,2)~=0))

temp_column = find([radon_results(:,2),monte_column(:,1)]' == max([radon_results(:,2),monte_column(:,1)]'));
columngood05 = (find(rem(temp_column,2)~=0))

allgood05 = intersect(unitgood05, columngood05);

temp_unit = find([radon_results(:,2),monte_unit(:,3)]' == max([radon_results(:,2),monte_unit(:,3)]'));
unitgood01 = (find(rem(temp_unit,2)~=0))

temp_column = find([radon_results(:,2),monte_column(:,3)]' == max([radon_results(:,2),monte_column(:,3)]'));
columngood01 = (find(rem(temp_column,2)~=0))

allgood01 = intersect(unitgood01, columngood01);
