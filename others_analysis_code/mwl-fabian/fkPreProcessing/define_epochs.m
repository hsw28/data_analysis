function [epoch_names, epochs]=define_epochs(posfile, epochfile)
%DEFINE_EPOCHS define epochs in recording session
%
%  [names,epochs]=DEFINE_EPOCHS(posfile,epochfile) given a diode position
%  file, this function will presents the user with a gui to define run
%  and/or sleep epochs. The epoch definitions will be saved to the epoch
%  file. The epoch names and times are also returned.
%

%  Copyright 2009 Fabian Kloosterman

%---VERBOSE---
VERBOSE_MSG_ID = mfilename; %#ok
VERBOSE_MSG_LEVEL = evalin('caller', 'get_verbose_msg_level();'); %#ok
%---VERBOSE---

%load previously defined epochs, if they exist
if ~exist(epochfile, 'file')
    epochs = [];
    def_answer = {'sleep1', 'run1', 'sleep2', 'run2', 'sleep3'};    
else
    verbosemsg(['Loading exisiting epoch definitions from ' epochfile])
    tmp = mwlopen(epochfile);
    tmp = load(tmp);
    def_answer = tmp.ep_name;
    epochs = [tmp.ep_start' tmp.ep_end'];
    clear tmp
end

%load diode position
if ~exist(posfile, 'file')
    error('define_epochs:noFile', 'No diode file found')
else
 
  verbosemsg(['Loading exisiting diode position data from ' posfile])
    
  f = mwlopen(posfile);
  posdata = load(f);
  timestamps = posdata.timestamp';
  posdata = [posdata.diode1' posdata.diode2'];
    
end

%let user enter/update epoch definitions
epochs = uisegment(epochs, timestamps, posdata(:,1));
nepochs = size(epochs,1);
if nepochs==0
    epochs = [timestamps(1) timestamps(end)];
    epoch_names = {'all'};
else
    dlg_prompt = cell(nepochs,1);
    for e=1:nepochs
        dlg_prompt{e} = ['Segment ' num2str(e) ': ' num2str(epochs(e,1)) ' - ' num2str(epochs(e,2))];
    end
    epoch_names = strtrim( inputdlg(dlg_prompt, 'Name your epochs', 1, def_answer) );
end

%save epochs
verbosemsg( ['Saving epoch definitions to ' epochfile] );

flds = mwlfield({'ep_name', 'ep_start', 'ep_end'}, {'string', 'double', ...
                    'double'}, {10 1 1});
data.ep_name = epoch_names;
data.ep_start = epochs(:,1)';
data.ep_end = epochs(:,2)';
f = mwlcreate(epochfile, 'feature', 'Fields', ...
              flds, 'FileFormat', 'ascii', 'Mode', 'overwrite', 'Data', data); %#ok
