function env = create_env_struct( kind, posdata )

if ~ischar(kind) || ~ismember(kind,{'simple track','complex track', ...
        'circular track', 'rectangular track', 'closed track', ...
        'circular field', 'rectangular field', 'custom field'} )
    error('create_env_struct:invalidArgument', 'Invalid environment kind')
end

env = struct( 'type', kind );

switch kind
    case {'simple track','complex track'}
        env.nodes = create_rectangle_struct(2,true);
        env.edges = create_polyline_struct(1,false,false,false);
    case 'circular track'
        env.edges = create_circle_struct(1,false);
    case 'rectangular track'
        env.edges = create_rectangle_struct(1,false);
    case 'closed track'
        env.edges = create_polyline_struct(1,true,false,false);
    case 'circular field'
        env.outline = create_circle_struct(1,false);
    case 'rectangular field'
        env.outline = create_rectangle_struct(1,false);
    case 'custom field'
        env.outline = create_polyline_struct(1,true,false,false);
end

if any( strcmp( kind, {'circular field', 'rectangular field', 'custom field'} ) )
    env.areas = struct( 'polylines', create_polyline_struct(0,true,false,true), ...
                        'circles', create_circle_struct(0,true), ...
                        'rectangles', create_rectangle_struct(0,true) );
end

if nargin>1
   
    if ~isnumeric(posdata) || ndims(posdata)>2 || size(posdata,2)~=2 || size(posdata,1)==0
        error('create_env_struct:invalidArgument', 'Invalid position data');
    end
    
    switch kind
        case {'simple track', 'complex track'}
            mi = nanmin(posdata);
            ma = nanmax(posdata);
            sz = (ma-mi)./10;
            env.nodes(1).center = mi;
            env.nodes(2).center = ma;
            [env.nodes.size] = deal( sz );
            env.edges.vertices = [mi;ma];
        case 'circular track'
            env.edges.center = nanmean(posdata);
            env.edges.radius = nanmean(sqrt(sum(bsxfun( @minus, posdata, env.edges.center ).^2,2)));
        case 'rectangular track'
            env.edges.center = nanmean(posdata);
            env.edges.size = nanmean(abs(bsxfun(@minus,posdata,env.edges.center))).*2;
        case 'closed track'
            valid = find(~isnan(sum(posdata,2)));
            idx = convhull( posdata(valid,1), posdata(valid,2) );
            env.edges.vertices = posdata( valid(idx), : );
        case 'circular field'
            env.outline.center = nanmean(posdata);
            env.outline.radius = prctile(sqrt(sum(bsxfun( @minus, posdata, env.outline.center ).^2,2)),95);
        case 'rectangular field'
            env.outline.center = nanmean(posdata);
            env.outline.size = prctile(abs(bsxfun(@minus,posdata,env.outline.center)),95).*2;
        case 'custom field'
            valid = find(~isnan(sum(posdata,2)));
            idx = convhull( posdata(valid,1), posdata(valid,2) );
            env.outline.vertices = posdata( valid(idx), : );
    end
    
end


function s=create_circle_struct(n,name)
if name
    s = struct('center', num2cell( zeros(n,2), 2 ), 'radius', num2cell( ones(n,1) ), 'name', '' );
    for k=1:n
        s(k).name = ['C' num2str(k)];
    end
else
    s = struct('center', num2cell( zeros(n,2), 2 ), 'radius', num2cell( ones(n,1) ) );
end

function s=create_rectangle_struct(n,name)
if name
    s = struct('center', num2cell( zeros(n,2), 2 ), 'size', num2cell( ones(n,2), 2 ), 'rotation', num2cell( zeros(n,1) ), 'name', '' );
    for k=1:n
        s(k).name = ['R' num2str(k)];
    end
else
    s = struct('center', num2cell( zeros(n,2), 2 ), 'size', num2cell( ones(n,2), 2 ), 'rotation', num2cell( zeros(n,1) ) );
end

function s=create_polyline_struct(n,isclosed,isspline,name)
if isclosed
    v = [0 0; 1 1; 0 1];
else
    v = [0 0; 1 1];
end
if name
    s = struct('vertices', repmat( {v}, n, 1 ), 'isclosed', repmat( {isclosed}, n, 1), 'isspline', repmat( {isspline}, n, 1 ), 'name', '' );
    for k=1:n
        s(k).name = ['P' num2str(k)];
    end
else
    s = struct('vertices', repmat( {v}, n, 1 ), 'isclosed', repmat( {isclosed}, n, 1), 'isspline', repmat( {isspline}, n, 1 ) );
end
