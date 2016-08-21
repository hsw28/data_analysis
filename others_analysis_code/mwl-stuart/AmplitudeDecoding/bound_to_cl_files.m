function bound_to_cl_files(edir, epoch, varargin)

[en et] = load_epochs(edir);
args.bound_file = [epoch, '-cbfile'];
args.time_range = et(ismember(en,epoch),:);

args = parseArgsLite(varargin,args);

outFields = {'id', 'time'};
fieldType = {'single', 'single'};
fieldSize = {1 1};

mwlFields = mwlfield(outFields,fieldType, fieldSize);

tt = load_exp_tt_list(edir);

count = 0;
for n=1:numel(tt)
    t = tt{n};
    
    bfile = fullfile(edir,t,args.bound_file);
    tfile = fullfile(edir,t,[t,'.tt']);
    cfile = fullfile(edir,t,[t,'.pxyabw']);
    
    if ~exist(bfile,'file')
        continue;
    end
    
    bdata = load(mwlopen(bfile));
    cdata = load(mwlopen(cfile));
    for clustN = 1:numel(bdata)
        count = count + 1;

        ind = cdata.time>=args.time_range(1) & cdata.time<=args.time_range(2);
        
        cl_file = fullfile(edir,t,epoch,['cl-',num2str(clustN)]);
                
        for boundN = 1:bdata(clustN).nbounds;
           pjNames = bdata(clustN).bounds(boundN).projection_names{1};
           p1 = pjNames{1};
           p2 = pjNames{2};
           vert = bdata(clustN).bounds(boundN).vertices;
           
           d1 = double(cdata.(p1));
           d2 = double(cdata.(p2));
           
           ind = ind & (inpolygon(d1,d2,vert(:,1), vert(:,2))); 
           
        end
        
        dataOut.id = cdata.id(ind);
        dataOut.time = cdata.time(ind);
        
        disp(['Writing: ', cl_file]);
        mwlcreate(cl_file,'feature', 'fields', mwlFields',...
            'FileFormat', 'ascii', 'Mode', 'overwrite',...
            'Data', dataOut);
        
    end                  
end

disp([num2str(count), ' cluster files have been written']);
end