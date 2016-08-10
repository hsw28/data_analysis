function m = metadata()

% Notes: see notes.txt

m.today = '052310';
m.basePath = ['~/Data/morpheus/',m.today];
m.loadTimewin = [1000, 2009];
m.checkedArteCorrectionFactor = false;
m.arteCorrectionFactor = 0;
m.rat_conv_table = morpheus_rat_conv_table();

% Position
m.pFileName = [m.basePath,'/l',m.today(3:4),'.p'];
m.linearize_opts.circular_track = false;
m.linearize_opts.calibrate_length = 0.78;
m.linearize_opts.click_points = ...
 [ 111.4138  103.3448   96.5172   92.3793   91.9655   95.6897  102.3103  118.8621  165.8276  222.1034  235.3448  245.0690  248.7931 250.6552  248.7931  242.1724  233.6897  226.0345  213.0000  189.6207  167.6897  157.1379  151.5517  150.1034  150.9310  154.6552 160.4483  169.3448  177.8276  185.6897  212.5862  246.5172  269.6897  274.8621; ...
   201.9967  171.6357  145.3775  118.5722  105.1696   93.6816   89.5788   81.9201   75.0821   67.4234   70.9792   78.3643   86.2965  93.9551  105.4431  113.9223  119.9398  122.1280  124.0427  125.9573  127.5985  135.2571  144.0098  152.7626  160.9683  168.3534 176.2856  182.0295  184.7648  183.9442  178.7473  171.3621  166.4387  165.0711]';
m.linearize_opts.calibrate_points = [ 210.5, 203.5; ...
                                      179.8, 67.7 ];


m.mua_filelist_fn = @morpheus_mua_filelist;
m.trode_groups_fn = @morpheus_trode_groups;
m.default_segment_style = 'ml';

m.ad_tts   = {'07','08','06','02','03','12','11','10', '13','14','15','24','23','18','17','16'};
m.arte_tts = {};
m.systemList = {'ad','ad'};

m.f1File   = 'j23.eeg';
m.f1TrodeLabels = {'07','08','06','02','03','12','11','10'};
m.f1Inds   = 1:8;
m.f2File   = 'k23.eeg';
m.f2TrodeLabels = {'13','14','15','24','23','18','17','16'};
m.f2Inds   = 1:8;

m.singleThetaChan = '06';
m.keep_list = [3     7     8     9    11    16    17    18    19    20    21    24    26    34    35    38    42    43    44    46    47    49    51    54    55    56   57    59    61    62];

% MUA
m.keepGroups = {'septal','mid','temporal','medial','lateral','proximal','distal'};
m.width_window = [13,Inf];
m.threshold = 150;
