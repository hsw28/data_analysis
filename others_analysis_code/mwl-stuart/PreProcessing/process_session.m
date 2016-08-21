function process_session(session_dir)

% Stuart Layton 2009

extract_session(session_dir);

create_epochs(session_dir);

replace_pos_file(session_dir);
