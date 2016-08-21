function copy_pxyabw_file(file, outfile, varargin)
% creates a binary version of a pxyabw file

args.time_range = [-Inf Inf];
args.fields = {'id','t_px', 't_py', 't_pa', 't_pb','time', 'random'};
args.fieldType = {'int32', 'int16', 'int16', 'int16', 'int16', 'double', 'double'};
args.fieldSize = {1 1 1 1 1 1 1};
args.rm_fields = {};

args = parseArgsLite(varargin, args);

fInd = ~ismember(args.fields, args.rm_fields);
args.fields = args.fields(fInd);
args.fieldSize = args.fieldSize(fInd);
args.fieldType = args.fieldType(fInd);

dataIn = load(mwlopen(file));
dInd = dataIn.time>=args.time_range(1) & dataIn.time<args.time_range(2);

dataOut = struct();

for i=1:numel(args.fields);
    f = args.fields{i};
    if ~isfield(dataIn,f) && ~strcmp(f,'random')
        error(['Field:',f,' does not exist!']);
    elseif strcmp(f,'random')
        dataOut.(f) = 20*rand(1,sum(dInd));
    else
        dataOut.(f) = dataIn.(f)(dInd);
    end
end


outFields = mwlfield(args.fields, args.fieldType, args.fieldSize);


f = mwlcreate(outfile, 'feature', 'fields', outFields,...
    'FileFormat', 'binary', 'Mode', 'overwrite', ...
    'Data', dataOut);
end





