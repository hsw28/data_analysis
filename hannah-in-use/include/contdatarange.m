function c = contdatarange(c)
% CONTDATARANGE update datarange field of a contdata struct
% 
% [m x 2] array of upper and lower data ranges for m channels

  nbad_start = c.nbad_start;
  if isnan(nbad_start), 
    nbad_start = 0;
  end

  nbad_end = c.nbad_end;
  if isnan(nbad_end), 
    nbad_end = 0;
  end
  
  c.datarange = [min(c.data(nbad_start+1:end-nbad_end,:)); ...
                 max(c.data(nbad_start+1:end-nbad_end,:))]';