#if defined _sub_setup_included
  #endinput
#endif
#define _sub_setup_included

#pragma reqlib sub_setup

native setup_registeroption(name[], version);
native setup_registerfield(field[]);
native setup_showmain(id);

forward setup_register_fw();
forward setup_loaded_fw(Handle:query);
forward setup_clear_fw(id);
forward setup_menu_fw(id);
