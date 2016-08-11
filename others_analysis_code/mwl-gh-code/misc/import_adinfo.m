function [ad] = import_adinfo(headerfile)

%function [ad] = import_adinfo(headerfile);
%
%Imports AD header info into each cluster
%
% $Id: import_adinfo.m 419 2007-08-29 23:16:05Z tjd $
%
% Tom Davidson (tjd@mit.edu)
  
%Modified from Linus Sun (linus@mit.edu) v.1.0 4/02
%Total rewrite 10/10/03 - TD

ad = struct;

if isempty(headerfile),
  return
end

fid=fopen(headerfile);

if fid == -1,
  ad = [];
  return
end

while 1
	hline = fgetl(fid);
	if ~ischar(hline), break, end
	tokens = cell2mat(regexp(hline, '^% (.+):\s*(.+)$', 'tokenExtents'));
	if size(tokens,1) == 2,
		t1 = hline(tokens(1,1):tokens(1,2));
		t2 = hline(tokens(2,1):tokens(2,2));
		if strcmp(t1, 'adversion'); % use string for version #
			ad.(t1) = t2;
			continue;
		end
		if strcmp(t1,'Probe')
			switch(t2);
				case '0'
					chans = [0:3];
				case '1'
					chans = [4:7];
				otherwise
					error ('Unrecognized probe number');
			end
			continue;
		end

		if ~strncmpi('channel', t1,7),
			if any (strcmpi (t1, {'rate',...
					'errors',...
					'disk_errors',...
					'spikelen',...
					'spikesep',...
					'spikesize'})),
				try
					ad.(t1) = str2num(t2); %uses 'dynamic field names'
        catch
					error(['err parsing non-chan line ''' hline ''' in ' headerfile]);
				end % catch block
			end
			continue;
		end

		% channel line
		[discard discard chtokens] = regexp (t1, 'channel (\d+) (\w+)');
		chtokens = cell2mat(chtokens);

		if size(chtokens,1) == 2
			chnostr = t1(chtokens(1,1):chtokens(1,2));
			chno = str2num(chnostr);
			chword = t1(chtokens(2,1):chtokens(2,2));

			if any (chno == chans)
				if any (strcmpi (chword, {'ampgain',...
						'adgain',...
						'filter',...
						'threshold',...
						'offset'}))

					try
						ad.(['chan' chnostr chword]) = str2num(t2);
          catch
						error(['err parsing chan line ''' hline ''' in ' headerfile]);
					end % catch block
				end % good chword?dir, tetsubdir
			end % good chno?
		else % <> 2 tokens
			error ('problem with channel regexp: <> 2 tokens returned');
		end % two tokens test
	else % <> 2 tokens
		continue;
		% 		error ('problem with hline regexp: <> 2 tokens returned');
	end % two tokens test
end %while loop
fclose(fid);
