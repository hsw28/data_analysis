function enter_session_info(session_dir) %#ok

    fields = {'Rat_ID', 'Session_ID', 'Rec_Date', 'Rec_Room', 'Other'}';
    questions = {'Rat ID (spl##)', 'Session ID (day##)', 'Date (MM/DD/YY)', 'Rec Room (rat#)', 'Other'}';
    answers = inputdlg(questions, 'Session Info');
    
    session_info = cell2struct(answers, fields);
    session_dir = '.';
    info_file_name = fullfile(session_dir, 'session_info.mat'); %#ok
    save info_file_name session_info;

end