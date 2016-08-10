function sdat = imspike(name,varargin)

% set this loose in a data directory to bring in all cluster files.
%
% root path is the folder in which all tetrode folders are located
% clusterprefix is a string to append to the beginning of each unit's name
% mandatoryclusterprifex is a search prefix used when attempting to import
%     a putative cluster file.  DEFAULT: 'cl-' .  If you want to try to
%     import all files, set value to [] (empty array)
% flagfilename is the name of a 'good dir' marker.  Specifying one means
%    only dirs with such a named file will be searched
% avoidfilename is the name of a 'bad dir' marker.  Specifying one means
%    that all dirs will be searched except those w/ this marker
% getwaveform is a bool switch for incorporating waveform data.  NOT
%     IMPLEMENTED YET
% epochs is a cell array of epoch directory names to search through.  It's
%     assumed that epoch dirs are located inside tetrode dirs.  Specifying
%     any names means that only named dirs will be searched
% noiseclustscore : set this, if you cut the noise cluster and label it w/ a
% cluster score, to that cluster score
% verbose is a debugging/reporting option

p = inputParser;
p.addRequired('name',@ischar);
p.addParamValue('rootpath',pwd,@ischar);
p.addParamValue('clusterprefix','cell_',@ischar);
p.addParamValue('mandatoryclusterprefix','cl-',@ischar);
p.addParamValue('flagfilename','',@ischar);
p.addParamValue('avoidfilename','',@ischar);
p.addParamValue('getwaveform',false,@islogical); % doesn't work yet
p.addParamValue('epochs',cell(0),@iscell);
p.addParamValue('verbose',false,@islogical);
p.addParamValue('noiseclusterscore',[],@isreal);
p.addParamValue('parm_extension','.pxyabw',@ischar);
p.addParamValue('arte_correction_factor',[]);
p.addParamValue('ad_dirs',cell(0));
p.addParamValue('arte_dirs',cell(0));
p.parse(name,varargin{:})
opt = p.Results;

opt.usebadflag = not(isempty(opt.avoidfilename));
opt.usegoodflag = not(isempty(opt.flagfilename));
opt.usemanclprefix = not(isempty(opt.mandatoryclusterprefix));

if(isempty(opt.arte_correction_factor))
    error('imspike:no_arte_correction','Must pass some value for arte_correction_factor');
end

if(opt.verbose)
    disp(opt);
end

% init sdat cluster vector
sdat = struct();
sdat.name = name;
sdat.nclust = 0;
sdat.clust = cell(0);
sdat.userdata = struct();

% Start in day's root-level directory
cd(opt.rootpath);

% Count directories
dlist = lfunc_getdirs(opt);
dnames = arrayfun(@(x) x.name, dlist,'UniformOutput',false);

% Keep directories mentioned by name as being arte or ad dirs
m_dnames = union( intersect(dnames, opt.ad_dirs), intersect(dnames,opt.arte_dirs));

dlist = dlist(arrayfun(@(x) any(strcmp(x.name, m_dnames)), dlist));

if(opt.verbose)
    disp(dlist);
end

% Start looking through directories.  In this version, we only look one
% level for epoch dirs, and one more level for parm files
for i = 1:numel(dlist)
    this_dir_name = dlist(i).name;
    cd(this_dir_name);
    if (opt.verbose) 
        disp(['Entered dir: ', this_dir_name]);
    end
    % first search for trode-level cluster files
    this_trode = this_dir_name;
    this_epoch = 'noepoch';
    this_clust_prefix = [opt.clusterprefix,this_trode,'_'];
    % call dir with cl-*
    d_trode = dir([opt.mandatoryclusterprefix, '*']);
    for j = 1:numel(d_trode);
        this_cl = lfun_get_cluster(d_trode(j).name,this_clust_prefix,this_epoch,this_trode,opt);
        if( any(strcmp( this_trode, opt.arte_dirs)))
            disp(['Correcting cluster ', d_trode(j).name, ' for arte time offset']);
            this_cl.stimes = this_cl.stimes + opt.arte_correction_factor;
            this_cl.data(:, strcmp(this_cl.featurenames,'time')) = this_cl.stimes';
        end
        if (this_cl == 0 && opt.verbose)
            display(['Import error with file ',filename]);
        end
        if(this_cl ~= 0)
            sdat.clust(numel(sdat.clust)+1) = this_cl;
            if(opt.verbose)
                display(['Added cluster', this_cl.name]);
            end
        end % end if cl seems good
    end % end for clusters in trode folder
    
    % Now go through individual epoch folders
    dlist2 = lfunc_getdirs(opt);
    pwd
    for j = 1:numel(dlist2)
        this_epoch = dlist2(j).name;
        if(opt.verbose)
            disp(['CDing into dir ', this_epoch]);
        end
        cd(this_epoch);
        d_trode = dir([opt.mandatoryclusterprefix,'*']);
        for k = 1:numel(d_trode)
            clear this_cl;
            this_clust_prefix = [opt.clusterprefix,this_trode,'_'];
            this_cl = lfunc_get_cluster(d_trode(k).name,this_clust_prefix,this_epoch,this_trode,opt);

            if( any(strcmp( this_trode, opt.arte_dirs)))
                disp(['Correcting cluster ', dlist2(j).name,', ', d_trode(k).name, ' for arte time offset']);
                this_cl.stimes = this_cl.stimes + opt.arte_correction_factor;
                this_cl.data(:, strcmp(this_cl.featurenames,'time')) = this_cl.stimes';
            end

            if (not(exist('this_cl','var')) && opt.verbose)
                display(['Import error with file ', this_cl.name]);
            end
            if (isstruct(this_cl))
                sdat.clust{numel(sdat.clust)+1} = this_cl;
                if (opt.verbose)
                    display(['Added cluster', this_cl.name]);
                end
            end % end if cl seems good
        end % end epoch dir loop
        cd('..'); % return to trode dir
        
    end % end trode dir loop
    cd('..'); % return to root dir
end
sdat

if( ~isempty( setdiff(dnames, m_dnames) ))
    disp(['Some directies labeled neither ad or arte:', setdiff(dnames,m_dnames)]);
end

return
end

function clust = lfunc_get_cluster(filename,prefix,epoch_name,trode_name,opt)
cl = cl2mat(filename);
if(not(exist('cl')))
    cl = [];
end
clust = newemptyclust();
clust.name = [prefix,filename];
clust.epochs = cell(1);
clust.epochs{1} = epoch_name;
clust.comp = trode_name(1:2);
clust.trode = trode_name;
clust.featurenames = cl.featurenames;
clust.data = cl.featuredata;
clust.stimes = clust.data(:,find(strcmp('time',clust.featurenames)));
clust.cl2mat_info = cl.info;
clust.from_tt_file = [opt.rootpath,'/', trode_name,'/',trode_name,'.tt'];
clust.from_parm_file = [opt.rootpath,'/', trode_name,'/',trode_name,opt.parm_extension];
clust.nspike = numel(clust.stimes);
if(opt.verbose)
    disp(['Found a cluster file: ', clust.name]);
end
return
end

function dlist = lfunc_getdirs(opt)
% Count directories
d = dir;
ndir = 0;
dir_index = [];
dlist = [];
for i = 1:numel(d);
    if(and(d(i).isdir, 1>(sum(strcmp(d(i).name,{'.','..'})))))
        ndir = ndir + 1;
        dir_index = [dir_index, i];
    end
end
if(opt.verbose)
    disp(['Counting directories in ', pwd, '.  Found ', num2str(ndir), ' directories.']);
end
for i = 1:numel(dir_index)
    if(opt.verbose)
       %disp(['CDing into dir ', d(dir_index(i)).name]); 
    end
    cd(d(dir_index(i)).name);
    if(and(...
            ( or( not(opt.usebadflag) , not(exist(opt.avoidfilename,'file')) )      ), ...
            ( or( not(opt.usegoodflag), (exist(opt.flagfilename,'file'))  )      )  ...
                ))
        dlist = [dlist, d(dir_index(i))];
    else
        if(opt.verbose)
            disp(['Caught avoid flag file or lacked good flag file in ', d(dir_index(i)).name]);
        end
    end
    cd ..;
end
if (opt.verbose)
    display('From lfunc_getdirs(): List of good dirs:');
    for i = 1:numel(dlist)
        display(dlist(i).name);
    end
end


    

return
end
        