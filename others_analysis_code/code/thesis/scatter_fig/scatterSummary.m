function scatterSummary()

X_total = [];
y_total = [];
fldTotal = [];
atyTotal = [];
timTotal = [];
fieldCellsTotal = [];
fieldsTotal = [];
xcorrMatTotal = [];
okPairsTotal = [];

metadatas = {yolanda_112511_metadata()  ...
            ,yolanda_120711_metadata()  ...
            ,morpheus_052310_metadata() ...
            ,caillou_112812_metadata()};
nDatasets = numel(metadatas);

names = cell(1,nDatasets+1);
bs = cell(1,nDatasets+1);
bints = cell(1,nDatasets+1);
pValues = cell(1,nDatasets+1);
        
for i = 1:numel(metadatas)
    m = metadatas{i};
    dName = [m.basePath,'/scatterData.mat'];
    if(exist(dName))
        load(dName)
    else
        d = loadData(m,'segment_style','areas');
        save(dName,'d')
    end
    if(strContains(metadatas{i}.basePath,'caillou'))
        okDirections = {'outbound'}
    else
        okDirections = {'outbound','inbound'};
    end
    
    [X_reg, y_reg, fld, aty, ...
        tim, fieldCells, fields, xcorr_r, xcorr_mat, ...
        lags, okPairs, ~] = ...
            full_xcorr_analysis(d,m, ...
            'ok_directions',okDirections,...
            'ok_pair','CA1,CA1','draw',false);
        
    %[X_reg,y_reg,fld,aty,tim,fieldCells,fields,xcorr_r,xcorr_mat] = ...
    %    scatterFigure(d,m,'draw',false);
    
    X_total = [X_total;X_reg];
    y_total = [y_total;y_reg];
    fldTotal = [fldTotal, reshape(fld,1,[])];
    atyTotal = [atyTotal, reshape(aty,1,[])];
    timTotal = [timTotal, reshape(tim,1,[])];
    fieldCellsTotal = [fieldCellsTotal, fieldCells];
    fieldsTotal = [fieldsTotal,fields];
    xcorrMatTotal = [xcorrMatTotal, reshape(xcorr_mat,1,[])];
    okPairsTotal = [okPairsTotal, reshape(okPairs,1,[])];
    
    [b,bint,~,~,stats] = regress(y_reg,X_reg);
    names{i} = metadatas{i};
    bs{i} = b;
    bints{i} = bint;
    pValues{i} = stats(4);
    nPairs{i} = size(y_reg,1);
end

i = nDatasets + 1;
[b,bint,~,~,stats] = regress(y_total,X_total);
names{i}.basePath = 'total';
bs{i} = b;
bints{i} = bint;
pValues{i} = stats(4);
nPairs{i} = sum(cell2mat(nPairs(1:nDatasets)));

scatterFigure([],[], 'fieldDists', fldTotal, ...
    'timeDists', timTotal, 'anatomyDists', atyTotal,...
    'fieldCells',fieldCellsTotal,'fields',fieldsTotal,...
    'xcorr_mat',xcorrMatTotal,'okPairs',okPairsTotal,...
    'X_reg',X_total,'y_reg',y_total,'lags',lags);

for i = 1:(nDatasets+1)
   disp(names{i}.basePath);
   disp(['b: ', num2str(reshape(bs{i},1,[]))]);
   disp(['ci: ' num2str(reshape(bints{i}(:,2) - bs{i},1,[]))]);
   disp(['p: ', num2str(pValues{i})]);
   disp(['n: ', num2str(nPairs{i})]);
end

end

function b = strContains(s,target)

    b = ~isempty(regexp(s,target,'ONCE'));

end