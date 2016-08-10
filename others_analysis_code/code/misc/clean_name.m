function new_name = clean_name(old_name)

new_name = old_name;
new_name(new_name == '_') = '.';