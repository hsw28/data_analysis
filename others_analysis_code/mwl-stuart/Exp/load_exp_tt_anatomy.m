function [tt loc] = load_exp_tt_anatomy(edir)

if ~exist(fullfile(edir, 'tetrode_anatomy.mat'),'file')
   f = define_exp_tt_anatomy(edir);           
   waitfor(f);
end

d = load(fullfile(edir, 'tetrode_anatomy.mat'));
d = d.tt_anatomy;

tt = d(:,1);
loc = d(:,2);