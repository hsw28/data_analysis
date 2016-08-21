function field = truncate_place_field(field, n_ind)
% removes n_ind indecies of data from both sides of a place field
%
% If field is a 12x1 vector and n_ind = 1 then field will be returned as a
% 1x12 vector with indexes 1 and end set to 0

for i=1:n_ind
    field(i)=0;
    field(length(field)+1-i) = 0;
end
    
