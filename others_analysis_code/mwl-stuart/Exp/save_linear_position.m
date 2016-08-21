function save_linear_position(f_name, data)

fields = mwlfield({'timestamp', 'lp', 'lv', 'xp', 'yp'}, ...
                {'double', 'double', 'double', 'double', 'double'}, ...
                {1 1 1 1 1});
   
head = header('Program', mfilename, 'Date', [datestr(now, 'ddd ') datestr(now, 'mmm dd HH:MM:SS yyyy')], 'Units', 'meters');


nf = mwlcreate(f_name, 'feature', 'Fields', fields, 'Header', head, 'Data', data, 'Mode', 'overwrite');
disp([f_name, ' saved!']);
