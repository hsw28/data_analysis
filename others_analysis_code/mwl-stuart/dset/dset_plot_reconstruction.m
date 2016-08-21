function [f a] = dset_plot_reconstruction(recon, position, varargin)

stdArgs = dset_get_standard_args();
args = stdArgs.plot_reconstruction();
args = parseArgs(varargin, args);

a = axescheck(args.axes);
if isempty(a) 
    f = figure('Position', [100 600 1130 350]);
    a = gca;
end

%% setup the reconstruction img
% check if multiple recon structs >1 & <4
% if so use them as the channels of the image
% else create a 3 channel image
img = [];

%if a single reconstruction is returned, ie one estimate for each timebin
if isnumeric(recon.pdf) && ismatrix(recon.pdf) && ~iscell(recon.pdf)
    if args.grayscale == 0
        img = recon(1).pdf;
        colormap('hot');
    elseif numel(recon)==1
        img = recon.pdf;

        if size(img,3)==1
            img = 1 - repmat(img, [1 1 3]);
        elseif size(img,3)~=3
            error('Invalid pdf size, it should be MxNx1 or MxNx3');
        end

    elseif numel(recon)<=3

        img(:,:,1) = recon(1).pdf;
        img(:,:,2) = recon(2).pdf;

        if numel(recon)==3
            img(:,:,3) = recon(3).pdf;
        else
            img(:,:,3) = 0;
        end

    else
        error('Invalid number of reconstruction structs provided');
    end
    pbins = recon(1).pbins;
%if pdf is a cell array of estiamtes, ie one for each trajectory type
elseif iscell(recon.pdf)
    img = recon.pdf{1};
    for i = 2:numel(recon.pdf)
        img = [img; recon.pdf{i}];
    end
    pbins = 1:size(img,1);
end
    
imagesc(recon(1).tbins, pbins, img, 'Parent', a);

if nargin>1 && ~isempty(position) && isstruct(position)

    if args.smooth_position~=1
        pos_lp = interp1(position.ts, position.linpos, recon(1).tbins);
    else
        pos_lp = interp1(position.ts, position.smooth_lp, recon(1).tbins);
    end

    line(recon(1).tbins, pos_lp, 'color', args.pos_color, 'linestyle', 'none', 'marker', args.pos_marker, 'parent', a);
end


pan xon;
zoom xon;

end