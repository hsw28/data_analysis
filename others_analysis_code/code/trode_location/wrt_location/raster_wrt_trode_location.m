function raster_wrt_trode_location(data, trode_x, trode_y, wrt_opt, varargin)

p = inputParser();
p.parse(varargin{:});
opt = p.Results;

if(~isempty(wrt.timewin)
    data = sdatslice(data,'timewin', wrt.timewin);
end


