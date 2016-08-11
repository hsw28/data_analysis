function new_sdat = cluster_match(sdat,varargin)

p = inputParser;

p.addParamValue('new_sdat_name','new_sdat',@ischar);

p.parse(varargin{:});

cm_h = p.Results;

%initialize gui, hide during construction
f = figure('Visible','on','Position',[360 500 800 750]);
guidata(f,cm_h);
cm_init_gui(f,sdat,1);

set(f,'Visible','on');