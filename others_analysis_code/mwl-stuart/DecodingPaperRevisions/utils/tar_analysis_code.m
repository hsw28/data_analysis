

cmd = 'tar cvzf decodingCode.tar.gz *.m scripts/*.m utils/*.m';


curDir = pwd;

cd ~/src/matlab/thesis/DecodingPaperRevisions/

unix(cmd);

cd(curDir);
