function tt_anatomy = jp_load_tt_anatomy(animal, day)
edir = jp_working_dir(animal, day);

if ~exist(edir,'dir')
    warning('%s directory does not exist', edir);
    tt_anatomy = [];
    return;
end

anatFile = fullfile(edir, 'tt_anatomy.mat');

if ~exist(anatFile, 'file')
    warning('%s file does not exist\nRun jp_define_tt_anatomy first', anatFile);
    tt_anatomy = [];
    return;
end

tmp = load(anatFile);
tt_anatomy = tmp.tt_anatomy;