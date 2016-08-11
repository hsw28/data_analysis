function m = blue_032813_metadata()

% And there are no notes for it.

% Notes: see notes.txt

m.today = '032813';
m.basePath = ['~/Data/blue/',m.today];
m.loadTimewin = [ 4512.0  5460.0];
m.checkedArteCorrectionFactor = false;
m.arteCorrectionFactor = 0;
m.rat_conv_table = blue_rat_conv_table();

% Position
m.pFileName = [m.basePath,'/l',m.today(3:4),'.p'];

m.linearize_opts.circular_track = true;
m.linearize_opts.calibrate_length = 0.78;
m.linearize_opts.click_points = ...
 [114.3103  102.1034   90.1034   78.9310   71.6897   69.4138   71.6897   76.2414   83.4828   92.3793  105.8276  121.1379  143.0690  168.3103  191.6897  210.7241  228.1034  243.0000  251.6897  256.8621  258.7241  256.2414  250.6552  241.1379  231.2069  217.7586  200.7931  177.8276  160.2414  141.4138; ...
  216.2746  205.4431  193.1346  176.3950  151.2856  126.1761  110.9136   94.6663   82.8501   71.0339   59.2177   47.8939   37.5547   36.5700   41.4934   49.3709   63.6488   82.8501   97.1280  113.3753  133.0689  154.2396  173.4409  191.1652  202.4891  211.3512  221.6904  228.5832  230.0602  228.5832]';
m.linearize_opts.calibrate_points = [ 67.3963  258.8710; ...
                                      126.9737  126.9737];


m.mua_filelist_fn = @blue_mua_filelist;
m.trode_groups_fn = @blue_trode_groups;

m.ad_tts = {'12','14','15','16','17','18','19','20','23','24','25','26','27','29','29','30'};

m.arte_tts = {'01','02','03','04','05','06','07','08','09','10','11','21','22'};

m.systemList = {'ad','ad','arte','arte'};

m.f1File   = 'j28.eeg';
m.f1TrodeLabels = {'30','29','28','27','26','25','24','23'};
m.f1Inds   = 1:8;
m.f2File   = 'k28.eeg';
m.f2TrodeLabels = {'20','19','18','17','16','15','14','12'};
m.f2Inds   = 1:8;

m.f3File = 'arte_lfp0.eeg';
m.f3Inds = 1:8;
m.f3TrodeLabels = {'13','11','10','09','08','07','06','05'};
m.f4File = 'arte_lfp1.eeg';
m.f4Inds = 1:6;
m.f4TrodeLabels = {'04','03','02','01','22','21'};

m.singleThetaChan = '02';
m.keep_list = [];

% MUA
m.keepGroups = {'CA1','ADT','CTX','RSC'};
m.width_window = [-Inf,Inf];
m.threshold = 150;

% Time blacklists
m.ctxBlacklist = {};