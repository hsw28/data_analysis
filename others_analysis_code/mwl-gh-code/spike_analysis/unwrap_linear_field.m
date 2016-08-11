function fNew = unwrap_linear_field(field, varargin)

    p = inputParser();
    p.addParamValue('ok_directions',{'outbound','inbound'});
    p.parse(varargin{:});
    opt = p.Results;

    bc = field.bin_centers;
    lastBin = bc(end);
    db = diff(bc(1:2));
    xs = bc + lastBin + db;
    xs = [bc, xs];

    fNew = field;
    fNew.bin_centers = xs;
    fNew.rate = zeros(size(xs));
    if(numel(bc) ~= 100 || numel(xs) ~= 200)
        a = 2 % Signals some kind of problem. 100, 200 expected values
    end
    if(any(strcmp('outbound',opt.ok_directions)))
      fNew.rate(1:numel(bc)) = field.out_rate;
    if(any(strcmp('inbound',opt.ok_directions)))
        fNew.rate((numel(bc)+1):end) = field.in_rate(end:(-1):1);
    end
    
end