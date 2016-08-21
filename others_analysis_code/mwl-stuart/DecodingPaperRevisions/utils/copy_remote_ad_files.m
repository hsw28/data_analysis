function copy_remote_ad_files(host, user)
%%

if nargin < 2 || nargin > 1000
    user = 'slayton';
end

if nargin <1 || nargin > 1000
    host = '10.121.43.56';
end

copy_remote_epoch_files(host, user);
copy_remote_tt_files(host, user);
copy_remote_pos_files(host, user);

end