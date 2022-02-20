#if defined _sub_options_included
  #endinput
#endif
#define _sub_options_included

#pragma reqlib sub_options

native options_registeroption(name[]);
native options_registerfield(field[]);
native options_showmain(id);

forward options_register_fw();
forward options_clear_fw(id);
forward options_menu_fw(id);
